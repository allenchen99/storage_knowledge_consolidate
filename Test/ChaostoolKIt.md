# 1. Install chaostoolkit and docker
```shell
# venv
python3 -m venv ~/.venvs/chaostk
source  ~/.venvs/chaostk/bin/activate

# install docker
pip install -U chaostoolkit
pip install docker

# create chaos folder
mkdir -p ~/chaos-experiments
cd ~/chaos-experiments
```
# 2. define chaos actions in chaos_docker_actions.py
```python
import logging
import random
import docker
import time

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s: %(message)s")

client = docker.from_env()

def list_containers(label_selector=None):
    """
    List all containers, optionally filtered by label_selector.
    """
    filters = {}
    if label_selector:
        filters["label"] = label_selector
    return client.containers.list(all=True, filters=filters)

def print_containers_status(containers, header="[Probe] Container status:"):
    """
    Print containers in a table format with consistent logging, 
    and show running count.
    """
    total = len(containers)
    running_count = sum(1 for c in containers if c.status == "running")
    logging.info(f"{header} [{running_count}/{total}] services are running\n")
    logging.info("Container Name      Status \n" + "-"*18 + "  " + "-"*7)
    for c in containers:
        status_str = c.status.upper()
        logging.info(f"{c.name:<18} {status_str:<7}")

    not_running = [c for c in containers if c.status != "running"]
    if not_running:
        logging.info(f"{header.replace('Container status','Containers NOT running')} [{len(not_running)}/{total} not running]")
        for c in not_running:
            logging.info(f"  - {c.name} ({c.status.upper()})")

def all_containers_running(label_selector=None):
    """
    Probe to check if all containers are running.
    Returns dict with 'ok' boolean and container details.
    """
    containers = list_containers(label_selector)
    print_containers_status(containers, header="[Probe] Container status:")
    all_running = all(c.status == "running" for c in containers)
    return {"ok": all_running, "containers": [{ "name": c.name, "status": c.status } for c in containers]}

def random_stop_containers(label_selector=None, num=1, signal="SIGKILL", dry_run=False):
    """
    Randomly stop a given number of running containers.
    Returns list of stopped containers.
    """
    containers = list_containers(label_selector)
    running = [c for c in containers if c.status == "running"]
    print_containers_status(running, header="[Action] Running containers before stop:")

    if not running:
        return {"stopped": [], "reason": "no_running_containers"}

    count = min(num, len(running))
    chosen = random.sample(running, count)
    logging.info("[Action] Selected containers to stop:")
    for c in chosen:
        logging.info(f"  - {c.name}")

    stopped = []
    for c in chosen:
        name = c.name
        if dry_run:
            stopped.append(name)
            continue
        try:
            # Kill the container with given signal
            c.kill(signal=signal)
            stopped.append(name)
            logging.info(f"[Action] Killed container: {name}")
        except Exception as e:
            stopped.append({"name": name, "error": str(e)})
            logging.warning(f"[Action] Failed to kill container {name}: {e}")

    logging.info("[Action] Containers stopped this run:")
    for s in stopped:
        if isinstance(s, str):
            logging.info(f"  - {s}")
        else:
            logging.info(f"  - {s['name']} (ERROR: {s['error']})")

    # Print container status after stopping
    remaining_containers = list_containers(label_selector)
    print_containers_status(remaining_containers, header="[Probe] Container status after action:")

    return {"stopped": stopped}

def restart_containers(label_selector=None):
    """
    Restart all containers matching label_selector.
    Wait 10 seconds after restart before printing status.
    """
    containers = list_containers(label_selector)
    restarted = []
    already_running = []

    for c in containers:
        name = c.name
        try:
            if c.status == "running":
                already_running.append(name)
            else:
                c.restart()
                restarted.append(name)
        except Exception as e:
            logging.warning(f"[Rollback] Failed to restart {name}: {e}")

    logging.info("[Rollback Summary] Restarted containers:")
    for r in restarted:
        logging.info(f"  - {r}")

    logging.info("[Rollback Summary] Already running containers:")
    for a in already_running:
        logging.info(f"  - {a}")

    # Wait 10 seconds to let containers stabilize
    time.sleep(10)

    # Print container status after rollback
    updated_containers = list_containers(label_selector)
    print_containers_status(updated_containers, header="[Rollback] Container status after 10s wait:")

```
# 3. Define configuration file
```json
{
  "version": "1.0.0",
  "title": "Random Docker Container Chaos (local venv)",
  "description": "Random Stop defined number of docker service",
  "steady-state-hypothesis": {
    "title": "At least N docker services are running（or all docker services are running）",
    "probes": [
      {
        "type": "probe",
        "name": "all_containers_running",
        "tolerance": {
	  "type": "jsonpath",
	  "path": "$.ok",
	  "expect": true
	},
        "provider": {
          "type": "python",
          "module": "chaos_docker_actions",
          "func": "all_containers_running",
          "arguments": {
            "label_selector": null
          }
        }
      }
    ]
  },
  "method": [
    {
      "type": "action",
      "name": "random_stop",
      "provider": {
        "type": "python",
        "module": "chaos_docker_actions",
        "func": "random_stop_containers",
        "arguments": {
          "label_selector": null,
	  "num":3,
          "signal": "SIGKILL"
        }ProductOS:
      }
    },
    {
      "type": "probe",
      "name": "post_kill_probe",
      "provider": {
        "type": "python",
        "module": "chaos_docker_actions",
        "func": "all_containers_running",
        "arguments": {
          "label_selector": null
        }
      }
    }
  ],
  "rollbacks": [
    {
      "type": "action",
      "name": "restart_all",
      "provider": {
        "type": "python",
        "module": "chaos_docker_actions",
        "func": "restart_containers",
        "arguments": {
          "label_selector": null
        }
      }
    }
  ]
}
```

# 4. Run Chaos Test
```shell
(chaostk) root@ProductOS ~/chaos-experiments# chaos run ./experiment.json
[2025-10-09 15:52:41 INFO] Validating the experiment's syntax
[2025-10-09 15:52:41 INFO] Experiment looks valid
[2025-10-09 15:52:41 INFO] Running experiment: Random Docker Container Chaos (local venv)
[2025-10-09 15:52:41 INFO] Steady-state strategy: default
[2025-10-09 15:52:41 INFO] Rollbacks strategy: default
[2025-10-09 15:52:41 INFO] Steady state hypothesis: At least N docker services are running（or all docker services are running）
[2025-10-09 15:52:41 INFO] Probe: all_containers_running
2025-10-09 15:52:41,192 INFO: [Probe] Container status: [17/17] services are running

2025-10-09 15:52:41,193 INFO: Container Name      Status 
------------------  -------
2025-10-09 15:52:41,193 INFO: service_1          RUNNING
2025-10-09 15:52:41,193 INFO: service_2          RUNNING
2025-10-09 15:52:41,193 INFO: service_3          RUNNING
2025-10-09 15:52:41,193 INFO: service_4          RUNNING
2025-10-09 15:52:41,193 INFO: service_5          RUNNING
2025-10-09 15:52:41,193 INFO: service_6          RUNNING
2025-10-09 15:52:41,193 INFO: service_7          RUNNING
2025-10-09 15:52:41,193 INFO: service_8          RUNNING
2025-10-09 15:52:41,193 INFO: service_9          RUNNING
2025-10-09 15:52:41,194 INFO: service_10         RUNNING
2025-10-09 15:52:41,194 INFO: service_11         RUNNING
2025-10-09 15:52:41,194 INFO: service_12         RUNNING
2025-10-09 15:52:41,194 INFO: service_13         RUNNING
2025-10-09 15:52:41,194 INFO: service_14         RUNNING
2025-10-09 15:52:41,194 INFO: service_15         RUNNING
2025-10-09 15:52:41,194 INFO: service_16         RUNNING
2025-10-09 15:52:41,194 INFO: service_17         RUNNING
[2025-10-09 15:52:41 INFO] Steady state hypothesis is met!
[2025-10-09 15:52:41 INFO] Playing your experiment's method now...
[2025-10-09 15:52:41 INFO] Action: random_stop
2025-10-09 15:52:41,307 INFO: [Action] Running containers before stop: [17/17] services are running

2025-10-09 15:52:41,307 INFO: Container Name      Status 
------------------  -------
2025-10-09 15:52:41,307 INFO: service_1          RUNNING
2025-10-09 15:52:41,307 INFO: service_2          RUNNING
2025-10-09 15:52:41,307 INFO: service_3          RUNNING
2025-10-09 15:52:41,307 INFO: service_4          RUNNING
2025-10-09 15:52:41,307 INFO: service_5          RUNNING
2025-10-09 15:52:41,307 INFO: service_6          RUNNING
2025-10-09 15:52:41,307 INFO: service_7          RUNNING
2025-10-09 15:52:41,307 INFO: service_8          RUNNING
2025-10-09 15:52:41,307 INFO: service_9          RUNNING
2025-10-09 15:52:41,308 INFO: service_10         RUNNING
2025-10-09 15:52:41,308 INFO: service_11         RUNNING
2025-10-09 15:52:41,308 INFO: service_12         RUNNING
2025-10-09 15:52:41,308 INFO: service_13         RUNNING
2025-10-09 15:52:41,308 INFO: service_14         RUNNING
2025-10-09 15:52:41,308 INFO: service_15         RUNNING
2025-10-09 15:52:41,308 INFO: service_16         RUNNING
2025-10-09 15:52:41,308 INFO: service_17         RUNNING
2025-10-09 15:52:41,308 INFO: [Action] Selected containers to stop:
2025-10-09 15:52:41,308 INFO:   - service_4
2025-10-09 15:52:41,308 INFO:   - service_9
2025-10-09 15:52:41,308 INFO:   - service_2
2025-10-09 15:52:41,935 INFO: [Action] Killed container: service_4
2025-10-09 15:52:42,783 INFO: [Action] Killed container: service_9
2025-10-09 15:52:44,063 INFO: [Action] Killed container: service_2
2025-10-09 15:52:44,063 INFO: [Action] Containers stopped this run:
2025-10-09 15:52:44,063 INFO:   - service_4
2025-10-09 15:52:44,063 INFO:   - service_9
2025-10-09 15:52:44,063 INFO:   - service_2
2025-10-09 15:52:44,285 INFO: [Probe] Container status after action: [14/17] services are running

2025-10-09 15:52:44,285 INFO: Container Name      Status 
------------------  -------
2025-10-09 15:52:44,285 INFO: service_1          RUNNING
2025-10-09 15:52:44,286 INFO: service_2          EXITED 
2025-10-09 15:52:44,286 INFO: service_3          RUNNING
2025-10-09 15:52:44,286 INFO: service_4          EXITED 
2025-10-09 15:52:44,286 INFO: service_5          RUNNING
2025-10-09 15:52:44,286 INFO: service_6          RUNNING
2025-10-09 15:52:44,286 INFO: service_7          RUNNING
2025-10-09 15:52:44,286 INFO: service_8          RUNNING
2025-10-09 15:52:44,286 INFO: service_9          EXITED
2025-10-09 15:52:44,286 INFO: service_10         RUNNING
2025-10-09 15:52:44,286 INFO: service_11         RUNNING
2025-10-09 15:52:44,286 INFO: service_12         RUNNING
2025-10-09 15:52:44,286 INFO: service_13         RUNNING
2025-10-09 15:52:44,287 INFO: service_14         RUNNING
2025-10-09 15:52:44,287 INFO: service_15         RUNNING
2025-10-09 15:52:44,287 INFO: service_16         RUNNING
2025-10-09 15:52:44,287 INFO: service_17         RUNNING
2025-10-09 15:52:44,287 INFO: [Probe] Containers NOT running after action: [3/17 not running]
2025-10-09 15:52:44,287 INFO:   - service_2 (EXITED)
2025-10-09 15:52:44,287 INFO:   - service_4 (EXITED)
2025-10-09 15:52:44,287 INFO:   - service_9 (EXITED)
[2025-10-09 15:52:44 INFO] Probe: post_kill_probe
2025-10-09 15:52:44,368 INFO: [Probe] Container status: [14/17] services are running

```
