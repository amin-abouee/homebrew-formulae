class LibrealsenseAT2500 < Formula
  desc "Intel RealSense D400 series and SR300 capture"
  homepage "https://github.com/IntelRealSense/librealsense"
  url "https://github.com/IntelRealSense/librealsense/archive/v2.50.0.tar.gz"
  sha256 "cafeb2ed1efe5f42c4bd874296ce2860c7eebd15a9ce771f94580e0d0622098d"
  license "Apache-2.0"
  head "https://github.com/IntelRealSense/librealsense.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "glfw"
  depends_on "libusb"
  depends_on "openssl@1.1"
  # Build on Apple Silicon fails when generating Unix Makefiles.
  # Ref: https://github.com/IntelRealSense/librealsense/issues/8090
  on_arm do
    depends_on xcode: :build
  end

  # Add your patches here, after the dependencies and before the install method
  patch :p1 do
    url "file://#{HOMEBREW_REPOSITORY}/Library/Taps/aabouee/homebrew-formulae/Patches/librealsense@2.50.0/cmake_patch1.patch"
    sha256 "d1e7474de95cbf7edfb65ff9b911e192f713d6f5655da8e2ee8fdc869cbaa92c"
  end

  patch :p0 do
    url "file://#{HOMEBREW_REPOSITORY}/Library/Taps/aabouee/homebrew-formulae/Patches/librealsense@2.50.0/unix_config_patch2.patch"
    sha256 "b785f30a98b906f23fdc619961243835025e25ae1f115bc19415f71999b38d33"
  end

  def install
    ENV["OPENSSL_ROOT_DIR"] = Formula["openssl@1.1"].prefix

    args = %W[
      -DENABLE_CCACHE=OFF
      -DBUILD_WITH_OPENMP=OFF
      -DCMAKE_INSTALL_RPATH=#{rpath}
    ]
    if Hardware::CPU.arm?
      args << "-DCMAKE_CONFIGURATION_TYPES=Release"
      args << "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
      args << "-GXcode"
    end

    system "cmake", "-S", ".", "-B", "build", *std_cmake_args, *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <librealsense2/rs.h>
      #include <stdio.h>
      int main()
      {
        printf(RS2_API_VERSION_STR);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-o", "test"
    assert_equal version.to_s, shell_output("./test").strip
  end
end