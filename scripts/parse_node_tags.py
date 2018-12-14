"""
Example input:
[
  {
    "ami_id": "ami-xxxxxxxxxxxxxxxxx",
    "asg_min_size": "1",
    "autoscaling_enabled": "0",
    "instance_type": "t2.medium",
    "key_name": "foo",
    "name": "t2.medium",
    "node_labels": "crowdai.com/dedicated=prometheus",
    "node_taints": "crowdai.com/dedicated=prometheusNoSchedule",
    "spot_price": ""
  }
]
"""
import json
import sys

tag_key = sys.argv[1]
worker_groups = json.loads(sys.argv[2])

node_labels = []
for wg in worker_groups:
  wg_labels = wg.get(tag_key)
  if not wg_labels:
    node_labels.append([])
    continue
  node_labels.append(wg_labels.split(','))

output = {
    'keys': [],
    'values': [],
    'start_idxs': [],
    'end_idxs': [],
}

start_idx = 0
for i, labels in enumerate(node_labels):
  label_count = len(labels)
  output['start_idxs'].append(str(start_idx))
  start_idx += label_count
  output['end_idxs'].append(str(start_idx))
  if labels and labels[0]:
    keys, values = zip(*[lbl.split('=') for lbl in labels])
    output['keys'].extend(keys)
    output['values'].extend(values)

flat_output = {key: ','.join(val) for key, val in output.items()}
flat_output['total_tags'] = str(start_idx)
print(json.dumps(flat_output, sort_keys=True))
