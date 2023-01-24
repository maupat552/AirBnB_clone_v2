from fabric.api import *
import os

env.hosts = ['xx-web-01', 'xx-web-02']

def do_deploy(archive_path):
    if not os.path.exists(archive_path):
        return False
    filename = os.path.basename(archive_path)
    dirname = filename.split('.')[0]

    # Upload the archive to the /tmp/ directory of the web server
    put(archive_path, '/tmp/')

    # Uncompress the archive to the folder /data/web_static/releases/<archive filename without extension> on the web server
    run(f"mkdir -p /data/web_static/releases/{dirname}")
    run(f"tar -xzf /tmp/{filename} -C /data/web_static/releases/{dirname}")

    # Delete the archive from the web server
    run(f"rm /tmp/{filename}")

    # Delete the symbolic link /data/web_static/current from the web server
    run("rm -rf /data/web_static/current")

    # Create a new the symbolic link /data/web_static/current on the web server, linked to the new version of your code 
    run(f"ln -s /data/web_static/releases/{dirname} /data/web_static/current")

    return True
