public with sharing class Paginator {
    
    public Integer pageSize {get; set;}
    public Integer totalPages {get; set;}
    public Integer totalRecords {get; set;}
    public Integer pageNumber {get; set;}
    public Map<Integer, String> lastIdPerPage {get; set;}
    public Boolean hasNext {get; set;}
    public Boolean hasPrevious {get; set;}
    private String query {get; set;}
    private String countQuery {get; set;}
    
    public Paginator(String query, String countQuery, Integer pageSize) {
        this.query = query;
        this.countQuery = countQuery;
        this.pageSize = pageSize;
        this.lastIdPerPage = new Map<Integer, String>();
        
        refreshData();
    }
    
    public List<SObject> getSObjects() {
        
        String whereById = (pageNumber > 1 ) ? ' AND Id > \''+ lastIdPerPage.get(pageNumber-1) +'\' ' : ''; 
        
        String orderByQ = 'ORDER BY Id';
        
        String queryLimit = 'LIMIT '+ pageSize;
        
        List<SObject> sobjects = Database.query(String.join(new String[]{ query, whereById, orderByQ, queryLimit }, ' '));

		        
        if(!lastIdPerPage.containsKey(pageNumber) && sobjects.size()>0)
        	lastIdPerPage.put(pageNumber, sobjects[sobjects.size() - 1].Id);
        
        return sobjects;
    }
    
    public void refreshData() {
        
        totalRecords = Database.countQuery(countQuery);
        totalPages =  Integer.valueOf((Decimal.valueOf(totalRecords) / Decimal.valueOf(pageSize)).round(System.RoundingMode.CEILING));
        
        if (pageNumber == null) {
            pageNumber = 1;
            
        } else if (pageNumber > totalPages && totalPages != 0) {
            pageNumber = totalPages;
            
        } else if (pageNumber <= 0) {
            pageNumber = 1;
        }
        
        hasNext =  pageNumber < totalPages;
        hasPrevious = pageNumber > 1;
    }
    
    public void setPageSize(Integer pageSize) {
        this.lastIdPerPage.clear();
        this.pageSize = pageSize;
        this.pageNumber = null;
        refreshData();
    }

    public void next() { 
        pageNumber++;
        refreshData();
    }
    
    public void previous() { 
        pageNumber--;
        refreshData();
    }
    
}