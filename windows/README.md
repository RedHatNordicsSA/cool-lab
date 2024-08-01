# Get the damned windows automated for demos

This directory saves the config I made to get Windows Server 2022 to
automatically install and available for Ansible. At this point it
works on my laptop (TM), but still fails with disks on OpenShift virt.

I used the following guides:

1. [Download iso](https://www.microsoft.com/en-US/evalcenter/evaluate-windows-server-2022)
4. I used driver disk from OCP, but on my laptop I downloaded the [fedora virtio-win disk](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.248-1/)
5. To generate the initial autounattend.xml file I manually insalled windows, and used the image tool to create such:
1. Install [Windows ADK and PE addon](https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install)
2. Get the install.wim from windows install disk Sources directory to windows
3. Create the new catalog and autounattend.xml using the image tool
6. I modified the generated autounattend.xml a bit, [instructions here](https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/)

If ever needed, get productkey from [this webpage](https://learn.microsoft.com/en-us/windows-server/get-started/kms-client-activation-keys)

Now booting with [this autounattend.xml](./autounattend.xml) works on my laptop.

I also stored the libvirt config for reference: [win2k22.xml](./win2k22.xml).

To create the autounattend CDROM I do this (the file is in windows_config dir:

```
mkisofs -o ~/VirtualMachines/win_unattended.iso -J -r windows_config/
```

To create new thin windows disk use:

```
qemu-img create -f qcow2 ~/VirtualMachines/win2k22-test.qcow2 80G
```

# TODO

1. Fix install on OCP
Check why the windows installer complains for disk setup on OCP. You find the
autounattended.xml content from ConfigMap in the same project, with a name
like: sysprep-win2k22-exuberant-gerbil-1kshj9. <-- DONE
2. Create example playbook for Ansible
