function release --description 'Sign and publish npm package'
    set VERSION (grep -oP '(?<="version": ")[^"]*' package.json)
    git add .
    git commit -S -m "Release $VERSION"
    git tag -s $VERSION -m $VERSION
    git push
end
