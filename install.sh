git clone https://github.com/Blobby-Boi/BlobeVM
cd BlobeVM
pip install textual
sleep 2
python3 installer.py
docker build -t blobevm . --no-cache
cd ..

sudo apt update
sudo apt install -y jq

mkdir Save
cp -r BlobeVM/root/config/* Save

# Check if Docker image was built successfully
if ! docker images | grep -q "^blobevm"; then
    echo "ERROR: Docker image build failed!"
    echo "Run: docker build -t blobevm BlobeVM/ --no-cache"
    exit 1
fi

json_file="BlobeVM/options.json"
echo "Removing any existing containers..."
docker rm -f BlobeVM 2>/dev/null || true

echo "Starting BlobeVM container..."
if jq ".enablekvm" "$json_file" | grep -q true; then
    docker run -d --name=BlobeVM -e PUID=1000 -e PGID=1000 --device=/dev/kvm --security-opt seccomp=unconfined -e TZ=Etc/UTC -e SUBFOLDER=/ -e TITLE=BlobeVM -p 3000:3000 --shm-size="2gb" -v $(pwd)/Save:/config --restart unless-stopped blobevm
else
    docker run -d --name=BlobeVM -e PUID=1000 -e PGID=1000 --security-opt seccomp=unconfined -e TZ=Etc/UTC -e SUBFOLDER=/ -e TITLE=BlobeVM -p 3000:3000 --shm-size="2gb" -v $(pwd)/Save:/config --restart unless-stopped blobevm
fi

if docker ps | grep -q BlobeVM; then
    echo ""
    echo "========================================"
    echo "✓ BLOBEVM WAS INSTALLED SUCCESSFULLY!"
    echo "========================================"
    echo ""
    echo "Access: http://localhost:3000"
    echo "Port: 3000"
else
    echo "ERROR: Container failed to start"
    docker logs BlobeVM 2>&1 | tail -20
    exit 1
fi
