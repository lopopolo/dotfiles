# Steps to Delete a Git Submodule

(I can never remember these)

```bash
SUBMODULE="path/to/submodule"
git rm --cached "$SUBMODULE"
vim .gitmodules # Deleting the lines about the submodule
vim .git/config # Deleting the lines about the submodule
rm -rf "$SUBMODULE"
```
