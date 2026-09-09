package main

import (
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

var dartPackageName = regexp.MustCompile(`^[a-z][a-z0-9_]*$`)

func cmdName(root string, args []string) error {
	fs := newFlagSet("name")
	pub := fs.String("pub", "", "new Dart package name (snake_case)")
	display := fs.String("display", "", "visible app name (iOS CFBundleDisplayName, Android label)")
	if err := fs.Parse(args); err != nil {
		return err
	}
	if *pub == "" {
		return fmt.Errorf("name: --pub is required")
	}
	if !dartPackageName.MatchString(*pub) {
		return fmt.Errorf("name: --pub must be a Dart package name (snake_case), got %q", *pub)
	}
	old, err := readPubspecName(root)
	if err != nil {
		return err
	}
	if old == *pub && *display == "" {
		fmt.Println("name: nothing to change")
		return nil
	}
	if old != *pub {
		n, err := replaceInRepo(root, "package:"+old+"/", "package:"+*pub+"/")
		if err != nil {
			return err
		}
		if err := replacePubspecName(root, old, *pub); err != nil {
			return err
		}
		if err := replaceIfPresent(root, "ios/Runner/Info.plist",
			"<string>"+old+"</string>", "<string>"+*pub+"</string>"); err != nil {
			return err
		}
		if err := replaceIfPresent(root, "android/app/src/main/AndroidManifest.xml",
			`android:label="`+old+`"`, `android:label="`+*pub+`"`); err != nil {
			return err
		}
		if err := rewritePubNameAnchors(root, old, *pub); err != nil {
			return err
		}
		fmt.Printf("name: %s → %s (%d files with package: imports)\n", old, *pub, n)
	}
	if *display != "" {
		if err := setDisplayName(root, *display); err != nil {
			return err
		}
		fmt.Printf("display name: %s\n", *display)
	}
	return nil
}

// README H1, ARCHITECTURE seed phrase, VS Code launch config name matching the Dart package.
func rewritePubNameAnchors(root, old, next string) error {
	if err := replaceIfPresent(root, "README.md", "# "+old+"\n", "# "+next+"\n"); err != nil {
		return err
	}
	if err := replaceIfPresent(root, "ARCHITECTURE.md",
		"one seed name (`"+old+"`)", "one seed name (`"+next+"`)"); err != nil {
		return err
	}
	return replaceIfPresent(root, ".vscode/launch.json",
		`"name": "`+old+`"`, `"name": "`+next+`"`)
}

func setDisplayName(root, display string) error {
	plist := filepath.Join(root, "ios/Runner/Info.plist")
	b, err := os.ReadFile(plist)
	if err != nil {
		return err
	}
	re := regexp.MustCompile(`(?s)(<key>CFBundleDisplayName</key>\s*<string>)[^<]+(</string>)`)
	updated := re.ReplaceAll(b, []byte("${1}"+display+"${2}"))
	if err := os.WriteFile(plist, updated, 0o644); err != nil {
		return err
	}
	manifest := filepath.Join(root, "android/app/src/main/AndroidManifest.xml")
	mb, err := os.ReadFile(manifest)
	if err != nil {
		return err
	}
	mre := regexp.MustCompile(`android:label="[^"]*"`)
	mb = mre.ReplaceAll(mb, []byte(`android:label="`+display+`"`))
	return os.WriteFile(manifest, mb, 0o644)
}

func replacePubspecName(root, old, next string) error {
	path := filepath.Join(root, "pubspec.yaml")
	b, err := os.ReadFile(path)
	if err != nil {
		return err
	}
	out := strings.Replace(string(b), "name: "+old+"\n", "name: "+next+"\n", 1)
	return os.WriteFile(path, []byte(out), 0o644)
}

func readPubspecName(root string) (string, error) {
	b, err := os.ReadFile(filepath.Join(root, "pubspec.yaml"))
	if err != nil {
		return "", err
	}
	re := regexp.MustCompile(`(?m)^name:\s*([A-Za-z_][A-Za-z0-9_]*)\s*$`)
	m := re.FindSubmatch(b)
	if m == nil {
		return "", fmt.Errorf("pubspec.yaml: no name:")
	}
	return string(m[1]), nil
}
