# TerminalBox

A Linux terminal sandbox that runs directly in your browser using x86 emulation. Built with [v86](https://github.com/copy/v86), TerminalBox provides a complete Linux environment without requiring any installation.

## 🚀 Live Demo

Visit the live instance: `https://yourusername.github.io/TerminalBox/`

*(Replace `yourusername` with the actual GitHub username once GitHub Pages is enabled)*

## ✨ Features

- **No Installation Required**: Runs entirely in your browser using WebAssembly
- **Full Linux Environment**: Complete Buildroot Linux distribution with standard tools
- **CTF Challenge Support**: Includes 8 CTF challenges (Easy to Very Hard)
- **Performance Optimized**: Resource preloading, parallel downloads, and optimized memory usage
- **User-Friendly Interface**: Command autocomplete, visual progress tracking, and session export

## 📦 CTF Challenges

This repository includes 8 CTF challenges that load directly into the browser emulator:

- **Challenge 1**: Hidden Files Explorer (Easy)
- **Challenge 2**: Process Detective (Easy)
- **Challenge 3**: Network Navigator (Medium)
- **Challenge 4**: Log File Forensics (Medium)
- **Challenge 5**: Permission Puzzle (Medium)
- **Challenge 6**: Archive Archaeology (Hard)
- **Challenge 7**: Script Debugger (Hard)
- **Challenge 8**: System Intrusion Analysis (Very Hard)

### Using Challenges

1. Wait for the emulator to boot (all challenges are automatically loaded)
2. Use `ls` to see available challenge directories
3. Navigate to a challenge with `cd <challenge-name>` (e.g., `cd challenge1-hidden-files`)
4. Use `ls` to see the challenge files
5. Read the instructions with `cat README.md`

## 🌐 GitHub Pages Setup

This repository is configured to be served via GitHub Pages:

1. **Enable GitHub Pages**:
   - Go to repository Settings → Pages
   - Under "Source", select "Deploy from a branch"
   - Select the branch (e.g., `main`)
   - Select "/ (root)" as the folder
   - Click Save

2. **Access Your Site**:
   - Main page: `https://yourusername.github.io/TerminalBox/`

3. **Custom Domain** (Optional):
   - Add a `CNAME` file with your custom domain
   - Configure DNS with your domain provider

## 💻 Local Development

To run TerminalBox locally and load CTF challenges, you need to serve the files through a local web server (not by opening the HTML file directly):

### Using Python (recommended)
```bash
cd TerminalBox
python3 -m http.server 8000
```
Then visit: `http://localhost:8000`

### Using Node.js
```bash
cd TerminalBox
npx http-server -p 8000
```
Then visit: `http://localhost:8000`

### Using PHP
```bash
cd TerminalBox
php -S localhost:8000
```
Then visit: `http://localhost:8000`

**Important**: Opening `index.html` directly in your browser (using `file://` protocol) will prevent CTF challenges from loading due to browser security restrictions (CORS policy). You must use a local web server.

### Rebuild the `ctf-basic.img` data disk

When you update files under `ctf-collection/ctf_basic`, regenerate the mounted data disk:

```bash
./scripts/build-ctf-basic-image.sh
```

This recreates `ctf-basic.img` (and `ctf-basic.dmg`) from `ctf-collection/ctf_basic`.

## 🛠️ Repository Structure

```
TerminalBox/
├── index.html              # Main Linux emulator interface (GitHub Pages homepage)
├── ctf-collection/         # CTF challenge source files
│   ├── challenge1-hidden-files/
│   │   ├── README.md
│   │   └── mystery_dir/    # Challenge files
│   ├── challenge4-log-forensics/
│   │   ├── README.md
│   │   └── access.log      # Challenge files
│   ├── ... (more challenges with pre-created files)
├── .nojekyll              # Prevents Jekyll processing for GitHub Pages
├── OPTIMIZATIONS.md       # Performance optimization documentation
└── README.md              # This file
```

## 🎯 How It Works

1. **Browser-Based Emulation**: Uses v86 to emulate x86 architecture in JavaScript/WebAssembly
2. **Buildroot Linux**: Lightweight Linux distribution optimized for browser execution
3. **Serial Console**: Commands are sent via virtual serial port, output captured in real-time
4. **Resource Optimization**: Preconnect hints and resource preloading reduce boot time to 10-30 seconds

## 📝 Usage

### Running Commands

1. Wait for Linux to boot (status indicator shows "Linux is ready")
2. Type a command in the input field (autocomplete suggestions appear)
3. Press Enter or click "Run" to execute
4. View output in the terminal window

### Available Features

- **Command Autocomplete**: Start typing for suggestions
- **Command History**: Use up/down arrows (when supported)
- **Cancel Running Commands**: Click "Cancel" or press Ctrl+C
- **Save Session**: Export terminal output to a text file
- **VGA Screen**: Toggle graphical display (for debugging)
- **Restart Linux**: Full system restart

## 🔧 Performance Optimizations

See [OPTIMIZATIONS.md](OPTIMIZATIONS.md) for detailed information about:
- DNS preconnect hints
- Resource preloading strategies
- Memory allocation optimization
- Progress tracking implementation
- Future optimization opportunities

## 📋 Requirements

### For Running TerminalBox
- Modern web browser with WebAssembly support
  - Chrome 57+, Firefox 52+, Safari 11+, Edge 79+
- Stable internet connection for initial resource download
- ~100MB of available memory

## 🤝 Contributing

Contributions are welcome! Areas for improvement:
- Additional CTF challenges
- Performance optimizations
- UI/UX enhancements
- Documentation improvements

## 📄 License

This project uses:
- [v86](https://github.com/copy/v86) - BSD-2-Clause License
- Buildroot Linux - GPL v2 License

## 🙏 Credits

- [v86](https://github.com/copy/v86) by copy - x86 virtualization in JavaScript
- [Buildroot](https://buildroot.org/) - Embedded Linux build system
- Kernel image hosted by Simon Willison

## 📞 Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Check existing documentation in the ctf-collection folder
- Review `OPTIMIZATIONS.md` for performance details
