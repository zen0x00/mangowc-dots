#!/bin/bash

log()   { printf "%b\n" "$1"; }
info()  { log "🔧 $1"; }
ok()    { log "✅ $1"; }
warn()  { log "⚠️  $1"; }
err()   { log "❌ $1"; }
