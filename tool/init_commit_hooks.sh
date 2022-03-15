#!/bin/sh

echo '#!/bin/sh' > .git/hooks/pre-commit
echo 'exec dart run dart_pre_commit' >> .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
