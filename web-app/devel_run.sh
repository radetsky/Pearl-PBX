#!/bin/bash
export FRONTEND_ROOT=$(dirname `realpath $0`)
export PEARLPBX_ROOT=$(realpath $FRONTEND_ROOT/..)
export PERL5LIB=$PEARLPBX_ROOT/lib:$FRONTEND_ROOT/lib:$PEARLPBX_ROOT/common/lib
export PEARLPBX_CONFIG_DIR=$PEARLPBX_ROOT/etc/
export LOG_STDERR=1
export STARMAN_DEBUG=1

/usr/bin/starman -E development --listen 127.0.0.1:10000 --workers 1 --preload-app $FRONTEND_ROOT/PearlPBX-GUI.psgi
