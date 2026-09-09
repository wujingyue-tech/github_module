package main

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestDartPackageName(t *testing.T) {
	ok := []string{"learn_flutter", "my_app", "a"}
	bad := []string{"LearnFlutter", "my-app", "1app", ""}
	for _, s := range ok {
		if !dartPackageName.MatchString(s) {
			t.Errorf("want valid %q", s)
		}
	}
	for _, s := range bad {
		if dartPackageName.MatchString(s) {
			t.Errorf("want invalid %q", s)
		}
	}
}

func TestRewritePubNameAnchors(t *testing.T) {
	root := t.TempDir()
	write := func(rel, body string) {
		t.Helper()
		path := filepath.Join(root, rel)
		if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(path, []byte(body), 0o644); err != nil {
			t.Fatal(err)
		}
	}
	write("README.md", "# old_app\n\nkeep `name --pub my_app`\n")
	write("ARCHITECTURE.md", "the template keeps one seed name (`old_app`) until you run `name`.\n")
	write(".vscode/launch.json", "{\n      \"name\": \"old_app\",\n      \"type\": \"dart\"\n}\n")
	if err := rewritePubNameAnchors(root, "old_app", "github_module"); err != nil {
		t.Fatal(err)
	}
	mustContain := func(rel, want string) {
		t.Helper()
		b, err := os.ReadFile(filepath.Join(root, rel))
		if err != nil {
			t.Fatal(err)
		}
		if !strings.Contains(string(b), want) {
			t.Fatalf("%s: want %q in\n%s", rel, want, b)
		}
	}
	mustContain("README.md", "# github_module\n")
	mustContain("README.md", "name --pub my_app")
	mustContain("ARCHITECTURE.md", "one seed name (`github_module`)")
	mustContain(".vscode/launch.json", `"name": "github_module"`)
}

func TestRewritePubNameAnchorsSkipsMissing(t *testing.T) {
	if err := rewritePubNameAnchors(t.TempDir(), "old_app", "new_app"); err != nil {
		t.Fatal(err)
	}
}

func TestBundleID(t *testing.T) {
	if !bundleID.MatchString("com.example.myapp") {
		t.Fatal("com.example.myapp")
	}
	if bundleID.MatchString("com") || bundleID.MatchString("com.example.my-app") {
		t.Fatal("rejected ids should fail")
	}
}
