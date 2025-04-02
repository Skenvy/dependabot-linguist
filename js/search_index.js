var search_data = {"index":{"searchIndex":["dependabot","linguist","dependabotfilevalidator","configdriftstatus","repository","linguist","blobhelper","language","all_directories()","all_ecosystem_classes()","all_sources()","checking_exists()","commit_new_config()","config_drift()","confirm_config_version_is_valid()","convert_to_detectable_type()","dependabot_file_path()","directories_per_ecosystem_validated_by_dependabot()","directories_per_linguist_language()","directories_per_package_ecosystem()","directories_per_package_manager()","ecodir_is_ignored()","existing_config()","file_fetcher_class_per_package_ecosystem()","files_per_linguist_language()","flatten_ecodirs_to_ecodir()","linguist_cache()","linguist_directories()","linguist_languages()","linguist_sources()","load_ecosystem_directories()","meta_config()","new()","new()","new_config()","parsed_schedule_interval()","patch_for_dependabot_linguist()","put_discovery_info()","ungroup_language()","write_new_config()","readme"],"longSearchIndex":["dependabot","dependabot::linguist","dependabot::linguist::dependabotfilevalidator","dependabot::linguist::dependabotfilevalidator::configdriftstatus","dependabot::linguist::repository","linguist","linguist::blobhelper","linguist::language","dependabot::linguist::repository#all_directories()","dependabot::linguist::repository#all_ecosystem_classes()","dependabot::linguist::repository#all_sources()","dependabot::linguist::dependabotfilevalidator::checking_exists()","dependabot::linguist::dependabotfilevalidator#commit_new_config()","dependabot::linguist::dependabotfilevalidator#config_drift()","dependabot::linguist::dependabotfilevalidator#confirm_config_version_is_valid()","linguist::language#convert_to_detectable_type()","dependabot::linguist::dependabotfilevalidator#dependabot_file_path()","dependabot::linguist::repository#directories_per_ecosystem_validated_by_dependabot()","dependabot::linguist::repository#directories_per_linguist_language()","dependabot::linguist::repository#directories_per_package_ecosystem()","dependabot::linguist::repository#directories_per_package_manager()","dependabot::linguist::dependabotfilevalidator#ecodir_is_ignored()","dependabot::linguist::dependabotfilevalidator#existing_config()","dependabot::linguist::repository#file_fetcher_class_per_package_ecosystem()","dependabot::linguist::repository#files_per_linguist_language()","dependabot::linguist::dependabotfilevalidator::flatten_ecodirs_to_ecodir()","dependabot::linguist::repository#linguist_cache()","dependabot::linguist::repository#linguist_directories()","dependabot::linguist::repository#linguist_languages()","dependabot::linguist::repository#linguist_sources()","dependabot::linguist::dependabotfilevalidator#load_ecosystem_directories()","dependabot::linguist::dependabotfilevalidator#meta_config()","dependabot::linguist::dependabotfilevalidator::new()","dependabot::linguist::repository::new()","dependabot::linguist::dependabotfilevalidator#new_config()","dependabot::linguist::dependabotfilevalidator#parsed_schedule_interval()","linguist::language#patch_for_dependabot_linguist()","dependabot::linguist::repository#put_discovery_info()","linguist::language#ungroup_language()","dependabot::linguist::dependabotfilevalidator#write_new_config()",""],"info":[["Dependabot","","Dependabot.html","",""],["Dependabot::Linguist","","Dependabot/Linguist.html","","<p>Provides a patched linguist to use to target dependabot relevant ecosystem blobs.\n"],["Dependabot::Linguist::DependabotFileValidator","","Dependabot/Linguist/DependabotFileValidator.html","","<p>Reads an existing dependabot file and determines how it should be updated to meet the suggested entried …\n"],["Dependabot::Linguist::DependabotFileValidator::ConfigDriftStatus","","Dependabot/Linguist/DependabotFileValidator/ConfigDriftStatus.html","",""],["Dependabot::Linguist::Repository","","Dependabot/Linguist/Repository.html","","<p>Repository wraps a Linguist::Repository, to discover “linguist languages” present in a repository, …\n"],["Linguist","","Linguist.html","","<p>rubocop:disable Style/Documentation\n"],["Linguist::BlobHelper","","Linguist/BlobHelper.html","",""],["Linguist::Language","","Linguist/Language.html","","<p>github.com/github/linguist/blob/v9.0.0/lib/linguist/language.rb\n"],["all_directories","Dependabot::Linguist::Repository","Dependabot/Linguist/Repository.html#method-i-all_directories","()","<p>Get ALL directories for the repo path.\n"],["all_ecosystem_classes","Dependabot::Linguist::Repository","Dependabot/Linguist/Repository.html#method-i-all_ecosystem_classes","()",""],["all_sources","Dependabot::Linguist::Repository","Dependabot/Linguist/Repository.html#method-i-all_sources","()","<p>Get ALL sources from ALL directories for the repo path.\n"],["checking_exists","Dependabot::Linguist::DependabotFileValidator","Dependabot/Linguist/DependabotFileValidator.html#method-c-checking_exists","(checking, exists)",""],["commit_new_config","Dependabot::Linguist::DependabotFileValidator","Dependabot/Linguist/DependabotFileValidator.html#method-i-commit_new_config","()","<p>The expected environment to run this final step in should have ‘git’ AND ‘gh’ available …\n"],["config_drift","Dependabot::Linguist::DependabotFileValidator","Dependabot/Linguist/DependabotFileValidator.html#method-i-config_drift","()",""],["confirm_config_version_is_valid","Dependabot::Linguist::DependabotFileValidator","Dependabot/Linguist/DependabotFileValidator.html#method-i-confirm_config_version_is_valid","()",""],["convert_to_detectable_type","Linguist::Language","Linguist/Language.html#method-i-convert_to_detectable_type","()",""],["dependabot_file_path","Dependabot::Linguist::DependabotFileValidator","Dependabot/Linguist/DependabotFileValidator.html#method-i-dependabot_file_path","()","<p>rubocop:disable Layout/IndentationWidth, Layout/ElseAlignment, Layout/EndAlignment\n"],["directories_per_ecosystem_validated_by_dependabot","Dependabot::Linguist::Repository","Dependabot/Linguist/Repository.html#method-i-directories_per_ecosystem_validated_by_dependabot","()","<p>directories_per_ecosystem_validated_by_dependabot maps each identified present ecosystem to a list of …\n"],["directories_per_linguist_language","Dependabot::Linguist::Repository","Dependabot/Linguist/Repository.html#method-i-directories_per_linguist_language","()","<p>directories_per_linguist_language inverts the linguist_cache map to “&lt;Language&gt;” =&gt; …\n"],["directories_per_package_ecosystem","Dependabot::Linguist::Repository","Dependabot/Linguist/Repository.html#method-i-directories_per_package_ecosystem","()","<p>directories_per_package_ecosystem squashes the map of directories_per_package_manager according to the …\n"],["directories_per_package_manager","Dependabot::Linguist::Repository","Dependabot/Linguist/Repository.html#method-i-directories_per_package_manager","()","<p>directories_per_package_manager splits and merges the results of directories_per_linguist_language; split …\n"],["ecodir_is_ignored","Dependabot::Linguist::DependabotFileValidator","Dependabot/Linguist/DependabotFileValidator.html#method-i-ecodir_is_ignored","(eco, dir)","<p>Is a yaml config file exists that looks like\n<p>ignore:\n\n<pre>directory:\n  /path/to/somewhere:\n  - some_ecosystem ...</pre>\n"],["existing_config","Dependabot::Linguist::DependabotFileValidator","Dependabot/Linguist/DependabotFileValidator.html#method-i-existing_config","()",""],["file_fetcher_class_per_package_ecosystem","Dependabot::Linguist::Repository","Dependabot/Linguist/Repository.html#method-i-file_fetcher_class_per_package_ecosystem","()","<p>file_fetcher_class_per_package_ecosystem maps ecosystem names to the class objects for each dependabot …\n"],["files_per_linguist_language","Dependabot::Linguist::Repository","Dependabot/Linguist/Repository.html#method-i-files_per_linguist_language","()","<p>files_per_linguist_language inverts the linguist_cache map to “&lt;Language&gt;” =&gt; [“&lt;file_path&gt;”, …\n"],["flatten_ecodirs_to_ecodir","Dependabot::Linguist::DependabotFileValidator","Dependabot/Linguist/DependabotFileValidator.html#method-c-flatten_ecodirs_to_ecodir","(ecosystem_directories_map)",""],["linguist_cache","Dependabot::Linguist::Repository","Dependabot/Linguist/Repository.html#method-i-linguist_cache","()","<p>linguist_cache, linguist.cache, is a map of “&lt;file_path&gt;” =&gt; [“&lt;Language&gt;”, …\n"],["linguist_directories","Dependabot::Linguist::Repository","Dependabot/Linguist/Repository.html#method-i-linguist_directories","()","<p>Get the list of all directories identified by linguist, that had their language mapped to a relevant …\n"],["linguist_languages","Dependabot::Linguist::Repository","Dependabot/Linguist/Repository.html#method-i-linguist_languages","()","<p>Wraps Linguist::Repository.new(~).languages\n"],["linguist_sources","Dependabot::Linguist::Repository","Dependabot/Linguist/Repository.html#method-i-linguist_sources","()","<p>Get the list of all sources from all directories identified by linguist, that had their language mapped …\n"],["load_ecosystem_directories","Dependabot::Linguist::DependabotFileValidator","Dependabot/Linguist/DependabotFileValidator.html#method-i-load_ecosystem_directories","(incoming: @load_ecosystem_directories)","<p>Expects an input that is the output of ::Dependabot::Linguist::Repository.new(~)‘s directories_per_ecosystem_validated_by_dependabot …\n"],["meta_config","Dependabot::Linguist::DependabotFileValidator","Dependabot/Linguist/DependabotFileValidator.html#method-i-meta_config","()",""],["new","Dependabot::Linguist::DependabotFileValidator","Dependabot/Linguist/DependabotFileValidator.html#method-c-new","(repo_path, remove_undiscovered: false, update_existing: true, minimum_interval: \"weekly\", max_open_pull_requests_limit: 5, verbose: false)",""],["new","Dependabot::Linguist::Repository","Dependabot/Linguist/Repository.html#method-c-new","(repo_path, repo_name, ignore_linguist: 0, verbose: false)",""],["new_config","Dependabot::Linguist::DependabotFileValidator","Dependabot/Linguist/DependabotFileValidator.html#method-i-new_config","()",""],["parsed_schedule_interval","Dependabot::Linguist::DependabotFileValidator","Dependabot/Linguist/DependabotFileValidator.html#method-i-parsed_schedule_interval","(interval)",""],["patch_for_dependabot_linguist","Linguist::Language","Linguist/Language.html#method-i-patch_for_dependabot_linguist","()",""],["put_discovery_info","Dependabot::Linguist::Repository","Dependabot/Linguist/Repository.html#method-i-put_discovery_info","()","<p>Print out the lists of languages, managers, and ecosystems found here.\n"],["ungroup_language","Linguist::Language","Linguist/Language.html#method-i-ungroup_language","()",""],["write_new_config","Dependabot::Linguist::DependabotFileValidator","Dependabot/Linguist/DependabotFileValidator.html#method-i-write_new_config","()",""],["README","","README_md.html","","<p>dependabot-linguist\n<p>Use linguist to check the contents of a <strong>local</strong> repository, and then scan for dependabot-core …\n"]]}}