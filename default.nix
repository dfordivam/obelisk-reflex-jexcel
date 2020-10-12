{ obelisk ? import ./.obelisk/impl {
    system = builtins.currentSystem;
    iosSdkVersion = "10.2";
    # You must accept the Android Software Development Kit License Agreement at
    # https://developer.android.com/studio/terms in order to build Android apps.
    # Uncomment and set this to `true` to indicate your acceptance:
    config.android_sdk.accept_license = true;
  }
}:
with obelisk;
project ./. ({ hackGet, ... }: {
  android.applicationId = "systems.obsidian.obelisk.examples.jexcel";
  android.displayName = "Obelisk JExcel Example";
  ios.bundleIdentifier = "systems.obsidian.obelisk.examples.jexcel";
  ios.bundleName = "Obelisk JExcel Example";

  packages = {
    reflex-jexcel = hackGet deps/reflex-jexcel;
    reflex-utils = hackGet deps/reflex-utils;
  };

  staticFiles = import ./static {};

})
