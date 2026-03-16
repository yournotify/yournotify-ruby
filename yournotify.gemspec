Gem::Specification.new do |spec|
  spec.name = "yournotify-ruby"
  spec.version = "0.1.0"
  spec.summary = "Ruby client for the current Yournotify API"
  spec.authors = ["Yournotify"]
  spec.files = Dir["lib/**/*.rb", "README.md"]
  spec.require_paths = ["lib"]
  spec.license = "MIT"
  spec.homepage = "https://github.com/yournotify/yournotify-ruby"
  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
    "bug_tracker_uri" => spec.homepage + "/issues"
  }
end
