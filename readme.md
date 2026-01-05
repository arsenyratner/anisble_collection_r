#

## first found

```yaml
distribution_firstfound_paths: []
distribution_firstfound_files:
  - "_{{ ansible_distribution | lower }}-{{ ansible_distribution_version | lower }}.yml"
  - "_{{ ansible_distribution | lower }}.yml"
  - "_{{ ansible_os_family | lower }}.yml"

distribution_firstfound:
  files: "{{ distribution_firstfound_files }}"
  paths: "{{ distribution_firstfound_paths }}"
  skip: true 

- name: "Load a variable file based on the OS distribution"
  ansible.builtin.include_vars: 
    file: "{{ lookup('ansible.builtin.first_found', distribution_firstfound) }}"

- name: Distribution specific tasks
  ansible.builtin.include_tasks:
    file: "{{ lookup('ansible.builtin.first_found', distribution_firstfound) }}"

```
