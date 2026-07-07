function flushdns --description 'Flush the macOS DNS cache (dscacheutil + mDNSResponder)'
    sudo dscacheutil -flushcache
    and sudo killall -HUP mDNSResponder
    and echo "✓ DNS cache flushed"
end
