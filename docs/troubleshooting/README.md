# Troubleshooting Guide

Common issues and solutions for the development environment setup.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Permission Errors](#permission-errors)
- [Network Issues](#network-issues)
- [Port Conflicts](#port-conflicts)
- [Service Issues](#service-issues)
- [AI Tools Issues](#ai-tools-issues)
- [VS Code Issues](#vscode-issues)
- [Documentation Issues](#documentation-issues)
- [Performance Issues](#performance-issues)
- [Getting Help](#getting-help)

## Installation Issues

### Script Fails to Start

**Problem**: Script exits immediately or shows permission errors.

**Solutions**:
1. Check file permissions:
   ```bash
   chmod +x scripts/setup-env.sh
   chmod +x scripts/lib/*.sh
   ```

2. Check if running as root:
   ```bash
   whoami
   # Should not be 'root'
   ```

3. Check disk space:
   ```bash
   df -h .
   # Should have at least 10GB free
   ```

### Homebrew Installation Fails

**Problem**: Homebrew installation fails or times out.

**Solutions**:
1. Check internet connection:
   ```bash
   ping github.com
   ```

2. Try manual installation:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. Check for existing installation:
   ```bash
   which brew
   brew --version
   ```

### Package Installation Fails

**Problem**: Individual packages fail to install.

**Solutions**:
1. Update Homebrew:
   ```bash
   brew update
   brew doctor
   ```

2. Check package availability:
   ```bash
   brew search package-name
   ```

3. Try installing manually:
   ```bash
   brew install package-name
   ```

## Permission Errors

### Permission Denied Errors

**Problem**: Script shows "Permission denied" errors.

**Solutions**:
1. Check file permissions:
   ```bash
   ls -la scripts/
   chmod +x scripts/*.sh
   ```

2. Check directory permissions:
   ```bash
   ls -la .
   chmod 755 .
   ```

3. Check if running in correct directory:
   ```bash
   pwd
   # Should be in the env-setup directory
   ```

### Sudo Required Errors

**Problem**: Script asks for sudo password.

**Solutions**:
1. Install Xcode Command Line Tools:
   ```bash
   xcode-select --install
   ```

2. Check if running as root (don't do this):
   ```bash
   whoami
   # Should be your username, not 'root'
   ```

## Network Issues

### Download Failures

**Problem**: Downloads fail or timeout.

**Solutions**:
1. Check internet connection:
   ```bash
   ping google.com
   curl -I https://github.com
   ```

2. Check proxy settings:
   ```bash
   echo $http_proxy
   echo $https_proxy
   ```

3. Try with different DNS:
   ```bash
   # Use Google DNS
   sudo dscacheutil -flushcache
   sudo killall -HUP mDNSResponder
   ```

### GitHub Access Issues

**Problem**: Cannot access GitHub repositories.

**Solutions**:
1. Check GitHub status:
   ```bash
   curl -I https://github.com
   ```

2. Check SSH keys (if using SSH):
   ```bash
   ssh -T git@github.com
   ```

3. Use HTTPS instead of SSH:
   ```bash
   git config --global url."https://github.com/".insteadOf "git@github.com:"
   ```

## Port Conflicts

### Port Already in Use

**Problem**: Services fail to start due to port conflicts.

**Solutions**:
1. Check what's using the port:
   ```bash
   lsof -i :1234  # LM Studio port
   lsof -i :3000  # Open WebUI port
   ```

2. Kill conflicting processes:
   ```bash
   kill -9 $(lsof -ti:1234)
   kill -9 $(lsof -ti:3000)
   ```

3. Change ports in config:
   ```yaml
   config:
     lm_studio_port: 1235
     open_webui_port: 3001
   ```

### Docker Port Conflicts

**Problem**: Docker containers fail to start.

**Solutions**:
1. Check Docker status:
   ```bash
   docker ps
   docker system df
   ```

2. Clean up Docker:
   ```bash
   docker system prune -a
   ```

3. Restart Docker:
   ```bash
   # macOS with Docker Desktop
   open -a Docker
   ```

## Service Issues

### Services Won't Start

**Problem**: Database or other services fail to start.

**Solutions**:
1. Check service status:
   ```bash
   brew services list
   ```

2. Start services manually:
   ```bash
   brew services start postgresql
   brew services start redis
   ```

3. Check logs:
   ```bash
   brew services info postgresql
   tail -f /opt/homebrew/var/log/postgresql.log
   ```

### Service Connection Issues

**Problem**: Cannot connect to services.

**Solutions**:
1. Check if services are running:
   ```bash
   ps aux | grep postgres
   ps aux | grep redis
   ```

2. Check connection strings:
   ```bash
   psql postgres
   redis-cli ping
   ```

3. Check firewall settings:
   ```bash
   sudo pfctl -s rules
   ```

## AI Tools Issues

### Ollama Issues

**Problem**: Ollama models fail to download or run.

**Solutions**:
1. Check Ollama status:
   ```bash
   ollama list
   ollama ps
   ```

2. Restart Ollama:
   ```bash
   pkill -f ollama
   ollama serve &
   ```

3. Check disk space:
   ```bash
   df -h
   # Models can be several GB
   ```

4. Try different model:
   ```bash
   ollama pull llama2:7b  # Smaller model
   ```

### LM Studio Issues

**Problem**: LM Studio won't start or connect.

**Solutions**:
1. Check if LM Studio is running:
   ```bash
   ps aux | grep -i lm
   ```

2. Check port availability:
   ```bash
   lsof -i :1234
   ```

3. Restart LM Studio:
   ```bash
   # Kill and restart the app
   pkill -f "LM Studio"
   open -a "LM Studio"
   ```

### Void IDE Issues

**Problem**: Void IDE won't connect to LM Studio.

**Solutions**:
1. Check Void IDE settings:
   ```bash
   cat ~/Library/Application\ Support/void/User/settings.json
   ```

2. Verify LM Studio is running on correct port:
   ```bash
   curl http://localhost:1234/v1/models
   ```

3. Reconfigure Void IDE:
   ```bash
   # Delete settings and let script reconfigure
   rm ~/Library/Application\ Support/void/User/settings.json
   ./scripts/setup-env.sh --only ai
   ```

## VS Code Issues

### Extensions Won't Install

**Problem**: VS Code extensions fail to install.

**Solutions**:
1. Check VS Code is running:
   ```bash
   ps aux | grep -i "visual studio code"
   ```

2. Kill VS Code processes:
   ```bash
   pkill -f "Visual Studio Code"
   ```

3. Install extensions manually:
   ```bash
   code --install-extension dbaeumer.vscode-eslint
   ```

### Extensions Not Working

**Problem**: Installed extensions don't work properly.

**Solutions**:
1. Restart VS Code completely
2. Check extension compatibility
3. Update VS Code:
   ```bash
   brew upgrade visual-studio-code
   ```

4. Reinstall extensions:
   ```bash
   code --uninstall-extension extension-id
   code --install-extension extension-id
   ```

## Documentation Issues

### Documentation Not Generated

**Problem**: Comprehensive documentation is not created after setup.

**Solutions**:
1. Check if documentation script exists:
   ```bash
   ls -la scripts/generate-csv-readme.sh
   ```

2. Run documentation generation manually:
   ```bash
   ./scripts/generate-csv-readme.sh
   ```

3. Check for errors in generation:
   ```bash
   ./scripts/generate-csv-readme.sh 2>&1 | tee docs-generation.log
   ```

### Documentation Not Opening

**Problem**: Documentation doesn't open in browser or VS Code.

**Solutions**:
1. Check if files exist:
   ```bash
   ls -la docs/ENVIRONMENT_SETUP_COMPLETE.*
   ```

2. Open manually:
   ```bash
   # Open in browser
   open docs/ENVIRONMENT_SETUP_COMPLETE.html
   
   # Open in VS Code
   code docs/ENVIRONMENT_SETUP_COMPLETE.md
   ```

3. Check pandoc installation:
   ```bash
   which pandoc
   pandoc --version
   ```

### Documentation Out of Date

**Problem**: Documentation doesn't reflect current installed packages.

**Solutions**:
1. Regenerate documentation:
   ```bash
   ./scripts/generate-csv-readme.sh
   ```

2. Check config.yaml for changes:
   ```bash
   git status config.yaml
   ```

3. Force regeneration:
   ```bash
   rm docs/ENVIRONMENT_SETUP_COMPLETE.*
   ./scripts/generate-csv-readme.sh
   ```

### HTML Rendering Issues

**Problem**: HTML documentation doesn't display properly.

**Solutions**:
1. Check if pandoc is installed:
   ```bash
   brew install pandoc
   ```

2. Regenerate HTML:
   ```bash
   pandoc docs/ENVIRONMENT_SETUP_COMPLETE.md -o docs/ENVIRONMENT_SETUP_COMPLETE.html --standalone
   ```

3. Check browser compatibility:
   ```bash
   # Try different browsers
   open -a "Google Chrome" docs/ENVIRONMENT_SETUP_COMPLETE.html
   open -a "Safari" docs/ENVIRONMENT_SETUP_COMPLETE.html
   ```

## macOS Configuration Issues

### macOS Settings Not Applied

**Problem**: macOS system preferences are not being configured.

**Solutions**:
1. Check if you're running on macOS:
   ```bash
   uname -s
   # Should return "Darwin"
   ```

2. Run macOS configuration manually:
   ```bash
   ./scripts/lib/macos.sh
   ```

3. Check for permission errors:
   ```bash
   # Look for permission-related errors in the output
   ./scripts/lib/macos.sh 2>&1 | grep -i "permission\|denied\|access"
   ```

### Dock Settings Not Applied

**Problem**: Dock settings are not being applied.

**Solutions**:
1. Restart Dock:
   ```bash
   killall Dock
   ```

2. Check current Dock settings:
   ```bash
   defaults read com.apple.dock
   ```

3. Reset Dock to defaults:
   ```bash
   defaults delete com.apple.dock
   killall Dock
   ```

### Finder Settings Not Applied

**Problem**: Finder settings are not being applied.

**Solutions**:
1. Restart Finder:
   ```bash
   killall Finder
   ```

2. Check current Finder settings:
   ```bash
   defaults read com.apple.finder
   ```

3. Reset Finder to defaults:
   ```bash
   defaults delete com.apple.finder
   killall Finder
   ```

### Accessibility Settings Permission Denied

**Problem**: Accessibility settings cannot be changed due to permissions.

**Solutions**:
1. Grant accessibility permissions:
   - Go to System Preferences > Security & Privacy > Privacy
   - Select "Accessibility" from the left sidebar
   - Add Terminal or your terminal app to the list
   - Check the box to enable it

2. Use System Preferences manually:
   - The script will show warnings for accessibility settings
   - Configure these manually in System Preferences

### Security Settings Require Admin

**Problem**: Security settings cannot be changed without admin privileges.

**Solutions**:
1. Run with sudo for security settings:
   ```bash
   sudo ./scripts/lib/macos.sh
   ```

2. Configure manually:
   - Go to System Preferences > Security & Privacy
   - Configure settings manually as needed

### FileVault Configuration

**Problem**: FileVault cannot be enabled automatically.

**Solutions**:
1. Enable FileVault manually:
   - Go to System Preferences > Security & Privacy > FileVault
   - Click "Turn On FileVault"
   - Follow the setup wizard

2. Use command line (requires admin):
   ```bash
   sudo fdesetup enable
   ```

## Performance Issues

### Slow Installation

**Problem**: Installation takes too long.

**Solutions**:
1. Check network speed:
   ```bash
   speedtest-cli
   ```

2. Reduce parallel jobs in config:
   ```yaml
   config:
     parallel_jobs: 1
   ```

3. Skip optional components:
   ```bash
   ./scripts/setup-env.sh --skip-models --skip-webui
   ```

### High Memory Usage

**Problem**: System becomes slow during installation.

**Solutions**:
1. Close other applications
2. Check available memory:
   ```bash
   top -l 1 | grep PhysMem
   ```

3. Reduce parallel jobs:
   ```yaml
   config:
     parallel_jobs: 1
   ```

## Getting Help

### Logs

Check installation logs for detailed error information:

```bash
# List all logs
ls -la logs/

# View latest log
tail -f logs/setup-*.log

# Search for specific errors
grep -i "error\|failed" logs/setup-*.log
```

### Health Checks

Run health checks to diagnose issues:

```bash
# Full health check
./scripts/setup-env.sh --dry-run

# Check specific components
brew services list
docker ps
ollama list
```

### Debug Mode

Run with verbose logging:

```bash
./scripts/setup-env.sh --verbose
```

### Community Support

- [GitHub Issues](https://github.com/your-username/env-setup/issues)
- [Discussions](https://github.com/your-username/env-setup/discussions)
- [Documentation](https://github.com/your-username/env-setup/tree/main/docs)

### Reporting Issues

When reporting issues, include:

1. Operating system version
2. Error messages from logs
3. Steps to reproduce
4. What you expected to happen
5. What actually happened

```bash
# System information
uname -a
sw_vers
brew --version

# Error logs
tail -n 50 logs/setup-*.log
```









