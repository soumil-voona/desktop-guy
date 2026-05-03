#!/bin/bash
set -e

echo "=== BlobeVM Rebuild Script ==="
echo ""

# Remove old failed build
echo "1. Cleaning up old containers and images..."
docker rm -f BlobeVM 2>/dev/null || true
docker rmi blobevm 2>/dev/null || true

echo ""
echo "2. Rebuilding Docker image..."
cd BlobeVM
docker build -t blobevm . --no-cache
cd ..

echo ""
echo "3. Creating Save directory..."
mkdir -p Save
cp -r BlobeVM/root/config/* Save 2>/dev/null || true

echo ""
echo "4. Checking configuration..."
json_file="BlobeVM/options.json"
if jq ".enablekvm" "$json_file" 2>/dev/null | grep -q true; then
    echo "   KVM support: ENABLED"
    KVM_FLAG="--device=/dev/kvm"
else
    echo "   KVM support: DISABLED"
    KVM_FLAG=""
fi

echo ""
echo "5. Starting BlobeVM container..."
docker run -d \
    --name=BlobeVM \
    -e PUID=1000 \
    -e PGID=1000 \
    $KVM_FLAG \
    --security-opt seccomp=unconfined \
    -e TZ=Etc/UTC \
    -e SUBFOLDER=/ \
    -e TITLE=BlobeVM \
    -p 3000:3000 \
    --shm-size="2gb" \
    -v $(pwd)/Save:/config \
    --restart unless-stopped \
    blobevm

echo ""
echo "6. Waiting for container to start..."
sleep 3

if docker ps | grep -q BlobeVM; then
    echo ""
    echo "=========================================="
    echo "✓ BLOBEVM WAS INSTALLED SUCCESSFULLY!"
    echo "=========================================="
    echo ""
    echo "Access at: http://localhost:3000"
    echo "Port: 3000"
    echo ""
    echo "Container details:"
    docker ps | grep BlobeVM
else
    echo ""
    echo "ERROR: Container failed to start"
    echo ""
    echo "Container logs:"
    docker logs BlobeVM 2>&1 | tail -30
    exit 1
fi
