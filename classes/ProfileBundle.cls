public with sharing virtual class ProfileBundle {
    public String profileId { get; protected set; }
    public String profileName { get; protected set; }
    public String licenseType { get; protected set; }
    public Map<String, Boolean> permissions { get; protected set; }
    public Map<Id, Map<String, Boolean>> permissions_content_type { get; protected set; }
    public Map<Id, Map<String, Boolean>> permissions_library { get; protected set; }
    public List<UserBundle> users { get; set; }
    public Boolean activated { get; protected set; }
    public Boolean licenseExpired { get; protected set; }
}