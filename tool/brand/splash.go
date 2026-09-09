package main

import (
	"fmt"
	"os"
	"path/filepath"
	"regexp"
)

func cmdSplash(root string, args []string) error {
	fs := newFlagSet("splash")
	image := fs.String("image", "", "light splash PNG")
	imageDark := fs.String("image-dark", "", "dark splash PNG (defaults to --image)")
	color := fs.String("color", "", "light background hex")
	colorDark := fs.String("color-dark", "", "dark background hex")
	if err := fs.Parse(args); err != nil {
		return err
	}
	if *image == "" {
		return fmt.Errorf("splash: --image is required")
	}
	if *imageDark == "" {
		*imageDark = *image
	}
	if err := copyPNG(resolvePath(root, *image), filepath.Join(root, "assets/splash/splash.png")); err != nil {
		return err
	}
	if err := copyPNG(resolvePath(root, *imageDark), filepath.Join(root, "assets/splash/splash_dark.png")); err != nil {
		return err
	}
	if *color != "" || *colorDark != "" {
		if err := patchSplashColors(root, *color, *colorDark); err != nil {
			return err
		}
	}
	if err := runDart(root, "run", "flutter_native_splash:create"); err != nil {
		return err
	}
	n, err := bumpBuild(root)
	if err != nil {
		return err
	}
	fmt.Printf("splash: wrote assets/splash/splash.png (+ dark); buildNumber %d\n", n)
	fmt.Println("install with a full flutter run; iOS caches the previous launch snapshot")
	return nil
}

func cmdIcon(root string, args []string) error {
	fs := newFlagSet("icon")
	image := fs.String("image", "", "1024px (or larger) PNG for the launcher icon")
	if err := fs.Parse(args); err != nil {
		return err
	}
	if *image == "" {
		return fmt.Errorf("icon: --image is required")
	}
	if err := copyPNG(resolvePath(root, *image), filepath.Join(root, "assets/splash/logo.png")); err != nil {
		return err
	}
	if err := runDart(root, "run", "flutter_launcher_icons"); err != nil {
		return err
	}
	if err := fixAssetCatalogGenerate(root); err != nil {
		return err
	}
	n, err := bumpBuild(root)
	if err != nil {
		return err
	}
	fmt.Printf("icon: wrote assets/splash/logo.png; buildNumber %d\n", n)
	fmt.Println("install with a full flutter run; uninstall the app if the home-screen icon is stale")
	return nil
}

func copyPNG(from, to string) error {
	b, err := os.ReadFile(from)
	if err != nil {
		return err
	}
	if len(b) < 8 || string(b[:8]) != "\x89PNG\r\n\x1a\n" {
		return fmt.Errorf("%s is not a PNG", from)
	}
	if err := os.MkdirAll(filepath.Dir(to), 0o755); err != nil {
		return err
	}
	return os.WriteFile(to, b, 0o644)
}

func patchSplashColors(root, color, colorDark string) error {
	path := filepath.Join(root, "flutter_native_splash.yaml")
	b, err := os.ReadFile(path)
	if err != nil {
		return err
	}
	s := string(b)
	if color != "" {
		re := regexp.MustCompile(`(?m)^(\s*)color:\s*"[^"]*"`)
		s = re.ReplaceAllString(s, `${1}color: "`+color+`"`)
	}
	if colorDark != "" {
		re := regexp.MustCompile(`(?m)^(\s*)color_dark:\s*"[^"]*"`)
		s = re.ReplaceAllString(s, `${1}color_dark: "`+colorDark+`"`)
	}
	return os.WriteFile(path, []byte(s), 0o644)
}

func fixAssetCatalogGenerate(root string) error {
	path := filepath.Join(root, "ios/Runner.xcodeproj/project.pbxproj")
	b, err := os.ReadFile(path)
	if err != nil {
		return err
	}
	const bad = "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = AppIcon;"
	const good = "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;"
	s := string(b)
	out := regexp.MustCompile(regexp.QuoteMeta(bad)).ReplaceAllString(s, good)
	if out == s {
		return nil
	}
	return os.WriteFile(path, []byte(out), 0o644)
}
