class Gtsam < Formula
  desc "GTSAM is a library of C++ classes that implement smoothing and mapping (SAM) in robotics and vision"
  homepage "https://github.com/borglab/gtsam"
  url "https://github.com/borglab/gtsam/archive/refs/heads/develop.zip"
  version "develop"
  head "https://github.com/borglab/gtsam.git"

  depends_on "cmake" => :build
  depends_on "boost" => :recommended
  depends_on "eigen"

  option "with-tbb", "Enable Intel Threading Building Blocks"
  option "with-tests", "Build with tests"
  option "with-unstable", "Build with unstable features"
  option "with-mkl", "Enable Intel Math Kernel Library"
  option "with-python", "Build with Python wrapper"
  option "without-boost", "Build without boost dependencies"
  option "without-tangent-preintegration", "Build without tangent-based preintegration"

  if build.with? "tbb"
    depends_on "tbb"
  end

  if build.with? "mkl"
    depends_on "intel-mkl"
  end

  if build.with? "python"
    depends_on "python@3.13"
  end

  def install
    args = std_cmake_args
    args << "-DCMAKE_CXX_STANDARD=17"
    args << "-DGTSAM_WITH_TBB=ON" if build.with? "tbb"
    args << "-DGTSAM_WITH_EIGEN_MKL=ON" if build.with? "mkl"
    args << "-DGTSAM_BUILD_TESTS=ON" if build.with? "tests"
    args << "-DGTSAM_BUILD_UNSTABLE=ON" if build.with? "unstable"
    args << "-DGTSAM_BUILD_PYTHON=ON" if build.with? "python"
    args << "-DGTSAM_BUILD_WITH_BOOST=OFF -DGTSAM_ENABLE_BOOST_SERIALIZATION=OFF" if build.without? "boost"
    args << "-DGTSAM_BUILD_WITH_TANGENT_PREINTEGRATION=OFF" if build.without? "tangent-preintegration"

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
    end

    if build.with? "python"
      # Install Python package
      cd "python/gtsam" do
        system "python3.13", *Language::Python.setup_install_args(prefix)
      end

      # Install pyparsing for Python
      system "python3.13", "-m", "pip", "install", "pyparsing"
    end
  end

  test do
    system "#{bin}/gtsam_version"
    if build.with? "python"
      system "python3.13", "-c", "import gtsam"
      system "python3.13", "-c", "import pyparsing"
    end
  end
end
