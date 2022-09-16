# EDGE instructions

We have some edge demos here as well. For that one needs to start with
decision if you connect it to
[Red Hat edge fleet management](https://console.redhat.com/edge/manage-images)
or not. If you go for the fleet management, use the previous link to build
and manage your fleet and images.

## Build and make edge image available for installs

We have setup for own edge process. There is
[image builder RHEL](https://rh-imgbuilder-09.cool.lab:9090/composer) where
we can build images.

For reference, here are some commands for the process from command line:

```sudo -u image-builder composer-cli blueprints list```

```sudo -u image-builder composer-cli blueprints push cool-lab-edge-9.toml```

```sudo -u image-builder composer-cli blueprints show cool-lab-edge-9```

```sudo -u image-builder composer-cli compose start-ostree cool-lab-edge-vmware edge-simplified-installer --url 'http://rh-imgbuilder-09.cool.lab:8080/repo' --ref rhel/9/x86_64/edge```

```sudo -u image-builder composer-cli image 53611de-a5dc-4f9f-9d8b-e32195d0a20f```

## Serve the image to installations

No matter which way you crerated the image, this is how you make it available
for the installs over network.

Start by loading image to podman image registry:

```podman load 53611de-a5dc-4f9f-9d8b-e32195d0a20f.tar```

check the image id and tag it (change id):

``` podman image tag f09cf26bab76 cool-lab-edge-installer:0.2```
``` podman image tag f09cf26bab76 cool-lab-edge-installer:latest```

and start serving the image repo:
```podman run --name edge -d -p 8080:8080 cool-lab-edge-installer```

At this point you have build, downloaded and started serving the edge image.

## Example of virtual install at KVM host

Here are couple of my commands to install Edge image on my laptop.

### Cool-lab baked image

For this you need the kickstart file [ks-rhel9-edge.cfg] and RHEL install
DVD or the installer downloaded from image composer.

```
virt-install \
--name cool-lab-edge \
--description 'RHEL Edge Demo from cool-lab' \
--memory 2048 \
--disk path=/home/itengval/VirtualMachines/cool-lab-edge.qcow2,size=10 \
--vcpus 2 \
--os-variant rhel9.0 \
--graphics none \
--network network=default \
--location=/home/itengval/VirtualMachines/cool-lab-edge-installer-0.2.iso \
--extra-args 'console=tty0 console=ttyS0,115200n8 inst.ks=file:/ks-rhel9-edge.cfg' \
--initrd-inject=/home/itengval/src/iot-hack/rhel-device/ks-rhel9-edge.cfg
```

Use your favority virtualization tool to attach to image, or use cocpit. I
Use virsh and virt-manager.

### Fleet management baked image

In this case, I just download the whole install iso file from edge composer
and use that. Folllow
[instructions here](https://access.redhat.com/documentation/en-us/edge_management/2022/html-single/create_rhel_for_edge_images_and_configure_automated_management/).

1. Download it to local directory, you'll have fleet_out.iso image.
2. Create activation keys, and drop them to ```[fleet_rhc_vars]``` -file.
3. Add permissions to directory ```chmod 777 .```
4. re-create iso
  ```podman run -it --rm -v ./:/isodir:Z quay.io/fleet-management/fleet-iso-util:latest```

Now you can use this iso to install the managed edge to VM:

```
virt-install \
--name rhel-edge-fleet-1 \
--description 'RHEL Edge Demo using fleet management' \
--memory 2048 \
--disk path=/home/itengval/VirtualMachines/fleet-edge-1.qcow2,size=10 \
--vcpus 2 \
--os-variant rhel9.0 \
--graphics none \
--network network=default \
--location=/home/itengval/VirtualMachines/fleet_out.iso \
```

Alternatively, you can go advanced and modify kickstart to customize the
install. For that see also modifications for isolinux-ikke.cfg.

Once kickstart is modified, you need to point isolinux.cfg to it, and recreate
the iso with modified files:

```
xorriso -indev ~/VirtualMachines/fleet_out.iso \
-outdev ~/VirtualMachines/fleet_out_serial.iso \
-compliance no_emul_toc \
-map "isolinux-ikke.cfg" "isolinux/isolinux.cfg" \
-map "fleet-ikke.ks" "fleet.ks" \
boot_image any replay
```

And finally install the VM using the modified stuff.

```
virt-install \
--name rhel-edge-fleet-1 \
--description 'RHEL Edge Demo using fleet management' \
--memory 2048 \
--disk path=/home/itengval/VirtualMachines/fleet-edge-1.qcow2,size=10 \
--vcpus 2 \
--os-variant rhel9.0 \
--graphics none \
--network network=default \
--location=/home/itengval/VirtualMachines/fleet_out.iso \
--extra-args 'console=tty0 console=ttyS0,115200n8 inst.ks=hd:LABEL=RHEL-9-0-0-BaseOS-x86_64:/fleet.ks'
```
