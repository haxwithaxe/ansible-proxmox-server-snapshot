ansible-proxmox-server
===================

This is snapshot of my personal playbook for prepping proxmox servers. Names have been changed so it won't work as is.

This does the following:
* SSH hardening
* Adds admin user
* Adds specially colored prompt for root and admin user.
* Adds login notification for root and admin user.


Requirements
------------

A proxmox server install.


Host Variables
--------------

- required_groups (list): A list of groups to add to the system.
- sshd_allowed_ssh_users_group: The group to allow ssh access to.
- sudoers_files (list): A list of sudoers files to deploy.
- user.groups (list): A list of groups to add the user to.
- user.home_dir (str): The user's home directory. 
- user.name (str): The user's name.
- user.password (str): The user's password hash. This should be encrypted with ansible vault. Defaults to `*` (disabled password).
- user.pubkeys (list): A list of ssh pubkeys to add the user's authorize_keys file.
- user.pubkeys_from_github_user (str): A github username to pull pubkeys from.
- user.pubkeys_from_gitlab_user (str): A gitlab.com username to pull pubkeys from.
- user.pubkeys_from_url (list): A list of URLs to pull ssh pubkeys from.
- user.ssh_user (bool): If true add this user to the `sshd_allowed_ssh_users_group` group.
- user.sudo_no_password (bool): If true add a sudoers file allowing all commands with no password.
- root_password: Override the password hash set with `user.password` where `user.name` is ``root``

Dependencies
------------

- devsec.hardening.ssh_hardening
- [haxwithaxe.keepalived](https://github.com/haxwithaxe/ansible-keepalived)
- [haxwithaxe.zfs_auto_snapshot](https://github.com/haxwithaxe/ansible-keepalived)

Examples
--------

`group_vars/all.yml`:
- User ``username``.
- Pull ssh pubkeys github.
- Set the root password.

```
---

users:
  - name: "username"
    home_dir: "/home/username"
    append_groups: yes
	groups:
	  - docker
    pubkeys_from_github_user: github-username
    ssh_user: yes
  - name: "root"
	password: <hashed password>
    home_dir: "/root"

required_groups:
  - name: ssh-users

sshd_allowed_ssh_users_group: ssh-users
sshd_moduli_size: 2048
sshd_rsa_host_key_size: 8192
```


License
-------

GPLv3


Author Information
------------------

Created by [haxwithaxe](https://github.com/haxwithaxe)
