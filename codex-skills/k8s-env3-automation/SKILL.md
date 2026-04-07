---
name: k8s-env3-automation
description: Execute Kubernetes and Kubespray operations with low interaction overhead in this environment. Use when tasks involve SSH, kubectl, ansible, or ansible-playbook and the user expects `conda activate env3.10`, stable temp dirs, and minimal repeated privilege prompts.
---

# K8s Env3 Automation

Use this workflow for cluster debugging, migration, and operational scripts in this environment.

## Core Rules

- Run commands through `zsh` with conda initialized:
  - `/usr/bin/zsh -lc 'source /home/lcz/anaconda3/etc/profile.d/conda.sh && conda activate env3.10 && <cmd>'`
- For Ansible commands, always set stable temp paths before execution:
  - `ANSIBLE_LOCAL_TEMP=/tmp/ansible-local-tmp-lcz`
  - `ANSIBLE_REMOTE_TMP=/tmp/ansible-remote-tmp-lcz`
  - `ANSIBLE_SSH_CONTROL_PATH_DIR=/tmp/ansible-cp-lcz`
- Prefer reusing already approved command prefixes to avoid repeated approval prompts.
- Batch compatible read-only checks in parallel; serialize state-changing actions.

## Execution Flow

1. Preflight
- Confirm target hosts are reachable (`ssh -o ConnectTimeout=8 ...`).
- Capture baseline snapshots before changes (`kubectl get nodes -o wide`, `etcd member list`, key pod health).

2. Change Execution
- Use Kubespray playbooks for role and topology changes when applicable.
- Avoid ad-hoc manual edits on control-plane components when Kubespray can reconcile.
- For destructive or role-changing operations, apply one major change at a time and verify immediately.

3. Verification
- Verify node roles and readiness.
- Verify etcd membership and health.
- Verify kube-system critical pods.
- Verify task-specific workload path (for example workflow trigger success).

4. Reporting
- Summarize: what changed, what passed, what remains.
- Include concrete timestamps and command outcomes.

## Command Templates

- Generic kubectl check:
```bash
/usr/bin/zsh -lc 'source /home/lcz/anaconda3/etc/profile.d/conda.sh && conda activate env3.10 && ssh -o StrictHostKeyChecking=no -o ConnectTimeout=8 <user>@<ip> "sudo kubectl --kubeconfig /etc/kubernetes/admin.conf get nodes -o wide"'
```

- Generic ansible-playbook run:
```bash
/usr/bin/zsh -lc 'source /home/lcz/anaconda3/etc/profile.d/conda.sh && conda activate env3.10 && export ANSIBLE_LOCAL_TEMP=/tmp/ansible-local-tmp-lcz && export ANSIBLE_REMOTE_TMP=/tmp/ansible-remote-tmp-lcz && export ANSIBLE_SSH_CONTROL_PATH_DIR=/tmp/ansible-cp-lcz && mkdir -p /tmp/ansible-local-tmp-lcz /tmp/ansible-remote-tmp-lcz /tmp/ansible-cp-lcz && cd /home/lcz/k8s/kubespray-local && ansible-playbook -i inventory/local/hosts.yaml <playbook> -u desay_ubuntu -b <extra-args>'
```

## Failure Patterns To Check First

- `UNREACHABLE` due to Ansible temp dir ownership/permissions.
- `DiskPressure` taint causing scheduling failures.
- Workflow succeeded upstream but downstream notification step failed (check pod logs/events).
- TLS/network path differs by node (validate from the exact node/pod where failure happens).
