#!/bin/sh
# create the wrapper

create_link()
{

echo "#!/bin/sh
# Needed to make symlinks/shortcuts work.
# the binaries must run with correct working directory
  cd \"$1\"
  ./$BINARY \$*
  exit \$? 
  " > $1/$TARGET
  
  chmod a+x $1/$TARGET
  
  # and then we must symlink to this
  # can't be done from setup.xml because it would symlink the binary
  if [ -n "$SETUP_SYMLINKSPATH" ] && [ -d $SETUP_SYMLINKSPATH ]
  then
    # the symlink might already exists, in case we will remove it
    if [ -h $SETUP_SYMLINKSPATH/$TARGET ]
    then
      echo "Removing existing $TARGET symlink"
      rm $SETUP_SYMLINKSPATH/$TARGET
    fi
  echo "Installing symlink $SETUP_SYMLINKSPATH/$TARGET -> $1/$TARGET"
  ln -s $1/$TARGET $SETUP_SYMLINKSPATH/$TARGET
  fi
}

BINARY=quake3.x86
TARGET=quake3
create_link $1
BINARY=quake3-smp.x86
TARGET=quake3-smp
create_link $1
