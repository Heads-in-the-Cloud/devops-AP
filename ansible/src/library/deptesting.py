#!/usr/bin/python

# Copyright: (c) 2022, Angel Soto Pellot <angel.pellot@smoothstack.com>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': ['preview'],
    'supported_by': 'community',
}

DOCUMENTATION = '''
---
module: deptesting
short_description: Test certbot and openssh client installation
version_added: "2.9"
description:
  - Test Certbot
  - Test OpenSSH clients
options:
  name:
    description:
      - Topic name
    required: false
'''

EXAMPLES = '''

'''

from ansible.module_utils.basic import AnsibleModule
from os import system
import re
import subprocess


class Dependency:
    def __init__(self, name: str, printed_name: str, run_command: dict, version_regex: str) -> None:
        self.name = name
        self.printed_name = printed_name
        self.run_command = run_command
        self.version_regex = version_regex


def check_installation(dep: Dependency, module: AnsibleModule, result: dict) -> None:
    status = system(f"which {dep.name}")
    if (status == 1):
        module.fail_json(
            msg=f"Module Failure! {dep.printed_name} installation not detected in PATH env var. Was it properly installed?", **result)
    else:
        result["module_log"] = result["module_log"] + \
            f"\n{dep.printed_name} installation was detected!"

    version = re.match(dep.version_regex,
                       module.params[f"{dep.name}_version"]).group(1)
    installed_version = re.search(
        dep.version_regex, str(subprocess.check_output(
            dep.run_command, stderr=subprocess.STDOUT), "utf-8"), re.IGNORECASE
    ).group(1)

    if (version != installed_version):
        msg = f"Module Failure! Version mismap: \nexpected version: {version}\nactual version: {installed_version}"
        module.fail_json(msg=msg, **result)
    else:
        result["module_log"] = result["module_log"] + \
            f"\n{dep.printed_name} installation matches expectation!"


def run_module() -> None:
    module_args = dict(
        state=dict(type='str', required=False, default='present'),
        certbot_version=dict(type='str', required=False, default=''),
        ssh_version=dict(type='str', required=False, default=''),
    )

    result = dict(
        module_log=''
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True,
    )

    if module.check_mode:
        module.exit_json(**result)

    certbot_module = Dependency(
        name="certbot",
        printed_name="Certbot",
        run_command=["certbot", "--version"],
        version_regex=r"certbot (.*)"
    )
    ssh_client_module = Dependency(
        name="ssh",
        printed_name="SSH Client",
        run_command=["ssh", "-V"],
        version_regex=r"OpenSSH_(\d.\w*)"
    )

    check_installation(certbot_module, module, result)
    check_installation(ssh_client_module, module, result)

    module.exit_json(**result)


def main() -> None:
    run_module()


if __name__ == '__main__':
    main()
