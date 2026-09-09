package main

import (
	"fmt"
	"os"
)

func main() {
	if err := newRoot().Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "brand: %v\n", err)
		os.Exit(1)
	}
}
