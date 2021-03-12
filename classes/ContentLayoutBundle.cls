public virtual with sharing class ContentLayoutBundle {
    public String contentLayoutId;
    public String label;
    public String name;
    public Map<String, List<AttributeBundle.ContentAttribute>> layoutAttributes { get; set; }

}