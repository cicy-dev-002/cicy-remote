pip install jupyterlab
jupyter --version
# Run Jupyter Lab in background (detached)
Start-Process `
-FilePath "jupyter" `
-ArgumentList @(
  "lab",
  "--IdentityProvider.token=$env:JUPYTER_TOKEN",
  "--ip=0.0.0.0",
  "--port=8888",
  "--ServerApp.allow_remote_access=True",
  "--ServerApp.trust_xheaders=True",
  "--no-browser"
) `
-WindowStyle Hidden
