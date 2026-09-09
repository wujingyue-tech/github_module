package main

import (
	"fmt"
	"os"
)

const usage = `brand — template branding for this Flutter repo.

Run from the repo root (uses fvm dart when .fvmrc exists).

  go -C tool/brand run .
  go -C tool/brand run . name --pub <snake_case> [--display "App Name"]
  go -C tool/brand run . package --id <reverse.domain.id>
  go -C tool/brand run . splash --image <png> [--image-dark <png>] [--color #FFFFFF] [--color-dark #121212]
  go -C tool/brand run . icon --image <png>
  go -C tool/brand run . bump

name     Dart package (pubspec + package: imports + CFBundleName + README H1 + ARCHITECTURE seed + VS Code launch name)
package  Android applicationId/namespace + iOS PRODUCT_BUNDLE_IDENTIFIER
splash   Copy launch images, flutter_native_splash:create, bump +buildNumber
icon     Copy launcher image, flutter_launcher_icons, fix pbxproj, bump +buildNumber
bump     Increment pubspec +buildNumber only (iOS launch-screen cache)
`

func main() {
	if err := run(os.Args[1:]); err != nil {
		fmt.Fprintf(os.Stderr, "brand: %v\n", err)
		os.Exit(1)
	}
}

func run(args []string) error {
	if len(args) == 0 || args[0] == "-h" || args[0] == "--help" || args[0] == "help" {
		fmt.Fprint(os.Stdout, usage)
		return nil
	}
	root, err := findRepoRoot()
	if err != nil {
		return err
	}
	switch args[0] {
	case "name":
		return cmdName(root, args[1:])
	case "package":
		return cmdPackage(root, args[1:])
	case "splash":
		return cmdSplash(root, args[1:])
	case "icon":
		return cmdIcon(root, args[1:])
	case "bump":
		n, err := bumpBuild(root)
		if err != nil {
			return err
		}
		fmt.Printf("buildNumber is now %d\n", n)
		return nil
	default:
		return fmt.Errorf("unknown command %q\n\n%s", args[0], usage)
	}
}
