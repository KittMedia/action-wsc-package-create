# WoltLab Suite Package Create Action

Creates a valid package for WoltLab Suite.

## Usage

Just add this action to your workflow to generate a package called <repository-name>.tar.gz in your root directory.

### Upload as artifact

```yaml
name: build package
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: WoltLab Suite Package Creation
        uses: KittMedia/action-wsc-package-create@v1
      - uses: actions/upload-artifact@v2
        with:
          name: ${{ github.event.repository.name }}.tar.gz
          path: ${{ github.event.repository.name }}.tar.gz
```

### Upload to remote server

```yaml
name: build package
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: WoltLab Suite Package Creation
        uses: KittMedia/action-wsc-package-create@v1
      - name: Install SSH key
        uses: shimataro/ssh-key-action@v2
        with:
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          known_hosts: ${{ secrets.KNOWN_HOSTS }}
      - run: ssh ${{ secrets.REMOTE_USER }}@${{ secrets.REMOTE_HOST }} "mkdir -p ${{ secrets.REMOTE_PATH_BASE }}/${{ github.event.repository.name }}/${{ github.sha }}"
      - run: scp ${{ github.event.repository.name }}.tar.gz ${{ secrets.REMOTE_USER }}@${{ secrets.REMOTE_HOST }}:${{ secrets.REMOTE_PATH_BASE }}/${{ github.event.repository.name }}/${{ github.sha }}
```

The package will then be uploaded to the remote host specified in the directory `<remote path>/repo-name/sha-hash/repo-name.tar.gz`.

#### Variables

##### KNOWN_HOSTS

Get a known host via `ssh-keyscan example.com`.

##### REMOTE_PATH_BASE

The path where the package should be uploaded.

##### REMOTE_HOST

Set your remote host, e. g. `example.com`.

##### REMOTE_USER

Set your remote user, e. g. `root` (please, do not!).

##### SSH_PRIVATE_KEY

Generate a private key with `ssh-keygen -m PEM -t rsa -b 4096`.

Make sure the public key is set on the target server in the `known_hosts` file of SSH.

## License

Our GitHub Actions are available for use and remix under the MIT license.
