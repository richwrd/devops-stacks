# Rancher Single Node Installation

## Prerequisites
- Docker installed and running
- Sufficient disk space for Rancher data

## Installation Instructions

### Important Considerations

#### Port Mapping
⚠️ **Attention**: The default configuration uses ports 80 and 443.

- If you're using **Nginx** as a reverse proxy:
  - Consider using **different ports** (e.g., `-p 8080:80 -p 8443:443`)
  - OR **remove port mapping entirely** (`-p` flags) for better security
  - Connect both containers to the **same Docker network** (e.g., `nginx-rancher-network`)
  
  ```shell
  # Example with custom network (no port exposure)
  docker network create nginx-rancher-network
  docker run -d --restart=unless-stopped \
    --network nginx-rancher-network \
    -v /opt/rancher:/var/lib/rancher \
    --privileged \
    --name rancher \
    rancher/rancher:latest
  ```

#### Volume Mapping
⚠️ **Storage**: Ensure the volume path has sufficient disk space.

- Default volume: `/opt/rancher` → `/var/lib/rancher`
- **Recommendation**: Map to a partition with adequate free space
- Monitor disk usage regularly as Rancher stores cluster data, logs, and backups

## References
- [Official Documentation](https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/other-installation-methods/rancher-on-a-single-node-with-docker)
https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade/other-installation-methods/rancher-on-a-single-node-with-docker


```shell
docker run -d --restart=unless-stopped \
  -p 80:80 -p 443:443 \
  -v /opt/rancher:/var/lib/rancher \
  --privileged \
  --name rancher \
  rancher/rancher:latest
```