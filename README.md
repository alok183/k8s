# k8s
- Avoid new line characters in screts. Convert string to base64.\
  [generate_secret.sh](generate_secret.sh)
  
- Start Saltstack server as k8s pod\
  Charts [helm-salt-server](helm-salt-server) \
  steps:
  1. do git clone
  2. Run helm3 command \
     helm install <release-name> <checkout_path>/helm-salt-server
 
- Projects several existing volume sources into the same directory\
  [projected-source.yaml](projected-source.yaml)
