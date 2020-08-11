use crate::{
    device::Device,
    instance::Instance,
    physical_device::{PhysicalDevice, QueueFamily},
    surface::Surface,
};
use anyhow::Result;
use ash::{
    extensions::{ext, khr},
    version::{DeviceV1_0, EntryV1_0, InstanceV1_0, InstanceV1_1},
    vk,
};
#[allow(unused_imports)]
use log::{debug, error, info, trace, warn};
use std::{
    ffi::{CStr, CString},
    sync::Arc,
};

#[derive(Clone, Copy, Default)]
pub struct SwapchainDesc {
    pub format: vk::SurfaceFormatKHR,
    pub dims: vk::Extent2D,
    pub vsync: bool,
}

pub struct Swapchain {
    pub(crate) fns: khr::Swapchain,
    pub(crate) raw: vk::SwapchainKHR,
    pub format: vk::SurfaceFormatKHR,
    pub images: Vec<vk::Image>,
    pub semaphores: Vec<vk::Semaphore>,
    pub next_semaphore: usize,

    // Keep a reference in order not to drop after the device
    #[allow(dead_code)]
    pub(crate) device: Arc<Device>,
}

pub struct SwapchainImage {
    pub image: vk::Image,
    pub image_index: u32,
    pub acquire_semaphore: vk::Semaphore,
}

pub enum SwapchainAcquireImageErr {
    RecreateFramebuffer,
}

impl Swapchain {
    pub fn enumerate_surface_formats(
        device: &Arc<Device>,
        surface: &Arc<Surface>,
    ) -> Result<Vec<vk::SurfaceFormatKHR>> {
        unsafe {
            Ok(surface
                .fns
                .get_physical_device_surface_formats(device.pdevice.raw, surface.raw)?)
        }
    }

    pub fn new(device: &Arc<Device>, surface: &Arc<Surface>, desc: SwapchainDesc) -> Result<Self> {
        let surface_capabilities = unsafe {
            surface
                .fns
                .get_physical_device_surface_capabilities(device.pdevice.raw, surface.raw)
        }?;

        let mut desired_image_count = surface_capabilities.min_image_count + 1;
        if surface_capabilities.max_image_count > 0
            && desired_image_count > surface_capabilities.max_image_count
        {
            desired_image_count = surface_capabilities.max_image_count;
        }

        //dbg!(&surface_capabilities);
        let surface_resolution = match surface_capabilities.current_extent.width {
            std::u32::MAX => desc.dims,
            _ => surface_capabilities.current_extent,
        };

        if 0 == surface_resolution.width || 0 == surface_resolution.height {
            anyhow::bail!("Swapchain resolution cannot be zero");
        }

        let present_modes = unsafe {
            surface
                .fns
                .get_physical_device_surface_present_modes(device.pdevice.raw, surface.raw)
        }?;

        let desired_present_mode = if desc.vsync {
            vk::PresentModeKHR::FIFO
        } else {
            vk::PresentModeKHR::MAILBOX
        };

        let present_mode = present_modes
            .iter()
            .cloned()
            .find(|&mode| mode == desired_present_mode)
            .unwrap_or(vk::PresentModeKHR::FIFO);

        let pre_transform = if surface_capabilities
            .supported_transforms
            .contains(vk::SurfaceTransformFlagsKHR::IDENTITY)
        {
            vk::SurfaceTransformFlagsKHR::IDENTITY
        } else {
            surface_capabilities.current_transform
        };

        let swapchain_create_info = vk::SwapchainCreateInfoKHR::builder()
            .surface(surface.raw)
            .min_image_count(desired_image_count)
            .image_color_space(desc.format.color_space)
            .image_format(desc.format.format)
            .image_extent(surface_resolution)
            .image_usage(vk::ImageUsageFlags::STORAGE)
            .image_sharing_mode(vk::SharingMode::EXCLUSIVE)
            .pre_transform(pre_transform)
            .composite_alpha(vk::CompositeAlphaFlagsKHR::OPAQUE)
            .present_mode(present_mode)
            .clipped(true)
            .image_array_layers(1)
            .build();

        let fns = khr::Swapchain::new(&device.instance.raw, &device.raw);
        let swapchain = unsafe { fns.create_swapchain(&swapchain_create_info, None) }.unwrap();

        let images = unsafe { fns.get_swapchain_images(swapchain) }.unwrap();
        let semaphore_create_info = vk::SemaphoreCreateInfo::default();

        let semaphores = (0..images.len())
            .map(|_| {
                unsafe {
                    device
                        .raw
                        .create_semaphore(&vk::SemaphoreCreateInfo::default(), None)
                }
                .unwrap()
            })
            .collect();

        Ok(Swapchain {
            fns,
            raw: swapchain,
            device: device.clone(),
            format: desc.format,
            images,
            semaphores,
            next_semaphore: 0,
        })
    }

    pub fn acquire_next_image(
        &mut self,
    ) -> std::result::Result<SwapchainImage, SwapchainAcquireImageErr> {
        let acquire_semaphore = self.semaphores[self.next_semaphore];
        let present_index = unsafe {
            self.fns.acquire_next_image(
                self.raw,
                std::u64::MAX,
                acquire_semaphore,
                vk::Fence::null(),
            )
        }
        .map(|(val, _)| val as usize);

        match present_index {
            Ok(present_index) => {
                self.next_semaphore = (self.next_semaphore + 1) % self.images.len();
                Ok(SwapchainImage {
                    image: self.images[present_index],
                    image_index: present_index as u32,
                    acquire_semaphore,
                })
            }
            Err(err)
                if err == vk::Result::ERROR_OUT_OF_DATE_KHR
                    || err == vk::Result::SUBOPTIMAL_KHR =>
            {
                Err(SwapchainAcquireImageErr::RecreateFramebuffer)
            }
            err @ _ => {
                panic!("Could not acquire swapchain image: {:?}", err);
            }
        }
    }

    pub fn present_image(&self, image: SwapchainImage, wait_semaphores: &[vk::Semaphore]) {
        let present_info = vk::PresentInfoKHR::builder()
            .wait_semaphores(&wait_semaphores)
            .swapchains(std::slice::from_ref(&self.raw))
            .image_indices(std::slice::from_ref(&image.image_index));

        unsafe {
            match self
                .fns
                .queue_present(self.device.universal_queue.raw, &present_info)
            {
                Ok(_) => (),
                Err(err)
                    if err == vk::Result::ERROR_OUT_OF_DATE_KHR
                        || err == vk::Result::SUBOPTIMAL_KHR =>
                {
                    // Handled in the next frame
                }
                err @ _ => {
                    panic!("Could not acquire swapchain image: {:?}", err);
                }
            }
        }
    }
}

impl Drop for Swapchain {
    fn drop(&mut self) {
        unsafe {
            self.fns.destroy_swapchain(self.raw, None);
        }
    }
}
