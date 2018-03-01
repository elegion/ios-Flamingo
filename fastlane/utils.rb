#!/usr/bin/ruby

def get_git_local_branch
  ref = (sh "git rev-parse --abbrev-ref HEAD").strip

  if_empty(ref) {
    raise "Can not get git ref to push"
  }

  if ref == "HEAD"
    raise "Can not trigger a build from detached git HEAD"
  end

  return ref
end


def get_git_remote_branch(local_ref)
  if_empty(local_ref) {
    local_ref = get_git_local_branch
  }

  remote_branch_name = (sh "git rev-parse --abbrev-ref --symbolic-full-name @{u}").strip
  if !remote_branch_name || remote_branch_name.empty?
    remote_branch_name = local_ref
  else
    remote_branch_name = remote_branch_name.sub("origin/", "")
  end

  return remote_branch_name
end


def if_not_empty(argument, &block)
  if argument && !argument.empty?
    yield(argument)
  end
end


def if_empty(argument, &block)
  if !argument || argument.empty?
    yield
  end
end


def get_xcode_project_bundle_id(project, target, configuration)
  return get_xcode_project_build_setting(project, target, configuration, "PRODUCT_BUNDLE_IDENTIFIER")
end


def get_xcode_project_team_id(project, target, configuration)
  return get_xcode_project_build_setting(project, target, configuration, "DEVELOPMENT_TEAM")
end

def get_xcode_project_team_name(project, target, configuration)
  return get_xcode_project_build_setting(project, target, configuration, "ELN_TEAM_NAME")
end

def get_xcode_project_fabric_api_token(project, target, configuration)
  return get_xcode_project_build_setting(project, target, configuration, "FABRIC_API_TOKEN")
end

def get_xcode_project_fabric_build_secret(project, target, configuration)
  return get_xcode_project_build_setting(project, target, configuration, "FABRIC_BUILD_SECRET")
end

def get_xcode_project_targets(project)
  output = sh "xcodebuild -project \"../#{project.shellescape}\" -list | awk '/Targets:/{f=1;next} /^$/{f=0} f' | sed 's/^ *//'"
  return output.split("\n")
end


def get_xcode_project_build_setting(project, target, configuration, setting)
  begin
    output = sh "xcrun xcodebuild clean -project \"../#{project.shellescape}\" -target \"#{target.shellescape}\" -configuration #{configuration.shellescape} -showBuildSettings | grep #{setting.shellescape}"
  rescue
    output = ""
  end
  return (output.split(setting + " = ").last || "").strip
end


def get_xcode_project_info_plist_path(project, target)
  return get_xcode_project_build_setting(project, target, "INFOPLIST_FILE")
end


def set_info_plist_value_with_key_path(info_plist, key, value)
  sh "/usr/libexec/PlistBuddy -c \"Set #{key.shellescape} '#{value.shellescape}'\" \"../#{info_plist.shellescape}\""
end


def resign_xcarchive(xcarchive, signing_identity, provisioning_profile, bundle_identifier)
  # set bundle id and signing identity for xcarchive info plist
  archive_info_plist = "#{xcarchive}/Info.plist"
  set_info_plist_value_with_key_path(archive_info_plist, ":ApplicationProperties:CFBundleIdentifier", bundle_identifier)
  set_info_plist_value_with_key_path(archive_info_plist, ":ApplicationProperties:SigningIdentity", bundle_identifier)

  # set bundle id for app info plist
  app_name = (sh "ls \"../#{xcarchive.shellescape}/Products/Applications/\" | cut -d . -f 1").strip
  app_info_plist = "#{xcarchive}/Products/Applications/#{app_name.shellescape}.app/Info.plist"
  set_info_plist_value_with_key_path(app_info_plist, "CFBundleIdentifier", bundle_identifier)

  # remove the old codesignature
  sh "rm -r \"../#{xcarchive.shellescape}/Products/Applications/#{app_name.shellescape}.app/_CodeSignature\" &2>/dev/null"

  # copy in the new provisioning profile
  sh "cp ../#{provisioning_profile.shellescape} ../#{xcarchive.shellescape}/Products/Applications/#{app_name.shellescape}.app/embedded.mobileprovision"

  # sign the package again
  sh "xcrun codesign -f -s #{signing_identity.shellescape} \"../#{xcarchive.shellescape}/Products/Applications/#{app_name.shellescape}.app\""
end
