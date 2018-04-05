# Ensure a clean commits history
if git.commits.any? { |c| c.message =~ /^Merge branch '#{github.branch_for_base}'/ }
  fail('Please rebase to get rid of the merge commits in this PR')
end
can_merge = github.pr_json["mergeable"]
is_merged = github.pr_json["merged"]

if is_merged
  warn("This PR was merged before CI was done.", sticky: false)
else
  warn("This PR cannot be merged yet.", sticky: false) unless can_merge
end

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 1000

#ENSURE THERE IS A SUMMARY FOR A PR
warn("Please provide a summary in the Pull Request description.") if github.pr_body.length < 5

# LINT Comments in for each Line
jsonpath = "lintreport.json"
contents = File.read jsonpath
require "json"
if contents.to_s == ''
	contents = "[]"
end
json = JSON.parse contents
json.each do |object|
   shortFile =  object["file"]
   shortFile.sub! "/Users/travis/build/Azure/Azure.iOS/", ''
   shortFile = shortFile.to_s || ''
   msg = object["reason"].to_s || ''
   severity = object["severity"].to_s || ''
   isError = severity == "Error"
   line = object["line"] || 1
   #only warn for files that were edited in this PR.
   if isError
    warn(msg, file: "/" + shortFile, line: line) if isError
   elsif git.modified_files.include? shortFile
   	warn(msg, file: "/" + shortFile, line: line) unless isError
   else
   	message(msg, file: shortFile, line: line)
   end
end
