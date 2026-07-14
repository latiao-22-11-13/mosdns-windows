package coremain

import "testing"

func TestSelectAssetForPlatformMatchesVersionedWindowsZip(t *testing.T) {
	assets := []githubAsset{
		{Name: "mosdns-0.7.0-linux-amd64.tar.gz"},
		{Name: "mosdns-0.7.0-windows-amd64.zip"},
	}

	got := selectAssetForPlatform("main", "windows", "amd64", false, assets)
	if got == nil {
		t.Fatal("expected versioned windows amd64 zip to be selected")
	}
	if got.Name != "mosdns-0.7.0-windows-amd64.zip" {
		t.Fatalf("selected asset = %q, want versioned windows zip", got.Name)
	}
}

func TestSelectAssetForPlatformPrefersVersionedWindowsV3Zip(t *testing.T) {
	assets := []githubAsset{
		{Name: "mosdns-0.7.0-windows-amd64.zip"},
		{Name: "mosdns-0.7.0-windows-amd64-v3.zip"},
	}

	got := selectAssetForPlatform("main", "windows", "amd64", true, assets)
	if got == nil {
		t.Fatal("expected versioned windows amd64 v3 zip to be selected")
	}
	if got.Name != "mosdns-0.7.0-windows-amd64-v3.zip" {
		t.Fatalf("selected asset = %q, want versioned windows v3 zip", got.Name)
	}
}

func TestFindV3AssetForPlatformMatchesVersionedWindowsZip(t *testing.T) {
	assets := []githubAsset{
		{Name: "mosdns-0.7.0-windows-amd64.zip"},
		{Name: "mosdns-0.7.0-windows-amd64-v3.zip"},
	}

	got := findV3AssetForPlatform("main", "windows", "amd64", assets)
	if got == nil {
		t.Fatal("expected versioned windows amd64 v3 zip to be found")
	}
	if got.Name != "mosdns-0.7.0-windows-amd64-v3.zip" {
		t.Fatalf("selected asset = %q, want versioned windows v3 zip", got.Name)
	}
}

func TestSelectAssetForPlatformMatchesVersionedWindowsArm64Zip(t *testing.T) {
	assets := []githubAsset{
		{Name: "mosdns-0.7.0-windows-arm64.zip"},
	}

	got := selectAssetForPlatform("main", "windows", "arm64", false, assets)
	if got == nil {
		t.Fatal("expected versioned windows arm64 zip to be selected")
	}
	if got.Name != "mosdns-0.7.0-windows-arm64.zip" {
		t.Fatalf("selected asset = %q, want versioned windows arm64 zip", got.Name)
	}
}
