# Configuration Presets

This directory contains predefined configuration files for different types of users and use cases. Each configuration is tailored to specific needs while maintaining the same structure as the main `config.yaml`.

## 🎯 Available Configurations

### **everything.yaml** - Complete Setup
- **Perfect for:** Complete development setups, power users, new Mac setups
- **Includes:** All available packages across all categories
- **Packages:** 113+ packages including AI tools, databases, productivity apps

### **minimal.yaml** - Essential Tools Only
- **Perfect for:** Quick setup, minimal systems, basic development
- **Includes:** Only the most essential development tools
- **Packages:** ~20 core packages (git, node, vscode, etc.)

### **webdev.yaml** - Web Development
- **Perfect for:** Frontend/backend web developers, full-stack developers
- **Includes:** Web development tools, modern terminals, productivity apps
- **Packages:** ~50 packages focused on web development

### **ai.yaml** - AI/ML Development
- **Perfect for:** AI researchers, ML engineers, data scientists
- **Includes:** AI tools, local LLMs, data science packages
- **Packages:** ~60 packages with AI/ML focus

### **mobile.yaml** - Mobile Development
- **Perfect for:** iOS/Android developers, React Native, Flutter developers
- **Includes:** Mobile development tools and simulators
- **Packages:** ~50 packages for mobile development

### **devops.yaml** - DevOps & Infrastructure
- **Perfect for:** DevOps engineers, SREs, infrastructure engineers
- **Includes:** Containerization, orchestration, monitoring, cloud tools
- **Packages:** ~80 packages with DevOps focus

### **design.yaml** - Design & Creative
- **Perfect for:** UI/UX designers, graphic designers, content creators
- **Includes:** Design tools, creative apps, productivity software
- **Packages:** ~30 packages for design work

### **gaming.yaml** - Gaming & Entertainment
- **Perfect for:** Gamers, streamers, content creators
- **Includes:** Gaming tools, streaming software, entertainment apps
- **Packages:** ~30 packages for gaming and entertainment

### **student.yaml** - Student & Learning
- **Perfect for:** Students, learners, coding bootcamp participants
- **Includes:** Essential learning tools, free software, educational resources
- **Packages:** ~50 packages for learning and development

### **senior.yaml** - Senior Developer
- **Perfect for:** Senior developers, tech leads, architects
- **Includes:** Advanced tools, monitoring, security, productivity
- **Packages:** ~90 packages with advanced development focus

## 🚀 How to Use

### Option 1: Use a Preset Configuration
```bash
# Use a specific configuration
./setup-env.sh install --config configs/webdev.yaml

# Or copy the config to use as your main config
cp configs/minimal.yaml config.yaml
./setup-env.sh install
```

### Option 2: Create Your Own Configuration
1. Copy any existing config as a starting point:
   ```bash
   cp configs/webdev.yaml configs/my-custom.yaml
   ```

2. Edit the configuration to match your needs:
   ```bash
   nano configs/my-custom.yaml
   ```

3. Use your custom configuration:
   ```bash
   ./setup-env.sh install --config configs/my-custom.yaml
   ```

## 📝 Configuration Structure

Each configuration file follows this structure:

```yaml
metadata:
  name: "Configuration Name"
  description: "Brief description"
  version: "1.0.0"

# Reference the main config for base settings
include: "../config.yaml"

# Override specific package categories
packages:
  core:
    brew: [list of brew packages]
  frontend:
    brew: [list of brew packages]
    cask: [list of cask packages]
  backend:
    brew: [list of brew packages]
    cask: [list of cask packages]
  business:
    brew: [list of brew packages]
    cask: [list of cask packages]
```

## 🔧 Customization Tips

1. **Start with a preset** that's closest to your needs
2. **Remove packages** you don't need by deleting them from the lists
3. **Add packages** by including them in the appropriate category
4. **Test your configuration** with `./setup-env.sh test --config your-config.yaml`
5. **Share your configuration** by creating a pull request!

## 📊 Package Categories

- **core**: Essential development tools (git, node, docker, etc.)
- **frontend**: Frontend development tools (terminals, editors, etc.)
- **backend**: Backend development tools (databases, APIs, etc.)
- **business**: Productivity and business applications

## 🤝 Contributing

Found a configuration that could be improved? Want to add a new preset? We'd love your contribution!

1. Fork the repository
2. Create your configuration in the `configs/` directory
3. Update this README with your new configuration
4. Submit a pull request

## 📚 Examples

### Minimal Web Developer
```yaml
packages:
  core:
    brew: ["git", "node", "pnpm", "docker"]
  frontend:
    cask: ["visual-studio-code", "warp"]
  business:
    cask: ["rectangle", "raycast"]
```

### AI Researcher
```yaml
packages:
  core:
    brew: ["git", "python@3.11", "docker", "postgresql"]
  business:
    cask: ["lm-studio", "cursor", "obsidian"]
```

### DevOps Engineer
```yaml
packages:
  core:
    brew: ["git", "docker", "kubectl", "helm", "awscli"]
  business:
    cask: ["cursor", "rectangle", "raycast"]
```
