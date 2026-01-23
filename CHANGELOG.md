# 1.2.2
 - Make the mod work again (i have no idea how long it's been broken).
   * The global Settings was being set to DefaultSettings before it was defined and thus returning null and breaking everything.
   * Maybe this only affected new instances that didn't have a config file yet?

# 1.2.1
 - Fix that updates a change to artifact's sprite ids found in ReturnsAPI 0.1.19
 - Update dependency versions for ReturnOfModding and ReturnsAPI

# 1.2.0
 - Port to use ReturnsAPI
 - Added configuration via the in-game settings menu.
    * So far it's just whether to draw an extra black drop-shadow and the ability to reset the config, offsets and colours are planned to be added.

# 1.1.0
 - Code refactor:
    * Make things more readable.
    * Enhance `debug_print` to new `log` function.
    * Unify constants into `Settings` table, to make things easier for _future configuration_
    * Add `LICENSE` and update `README.md` appropriately.
    * Added a screen-grabbed preview of how the mod looks in-game
    * Reduced calls to `Global`/`gm.get_global_get()` and make them consistent.
    * Sanity checks

# 1.0.0
 - Initial release.
