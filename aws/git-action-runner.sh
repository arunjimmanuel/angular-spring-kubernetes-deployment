echo ">>> Setting up GitHub Actions runner..."
mkdir -p actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.323.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.323.0/actions-runner-linux-x64-2.323.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.323.0.tar.gz
rm -f ./actions-runner-linux-x64-2.323.0.tar.gz

echo ">>> Encoding kubeconfig in base64:"
base64 -w 0 ~/.kube/config
echo -e "\n>>> Script complete!"