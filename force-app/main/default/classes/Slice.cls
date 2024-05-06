// Credits: https://newbedev.com/apex-array-slice
public with sharing class Slice {
	private List<Object> olist;

	public Slice(List<Object> olist){
		this.olist = olist;
	}

	public List<Object> slice(){
		return olist.clone();
	}

	public List<Object> slice(Decimal x_begin){
		Integer start = x_begin == NULL ? 0 : (Integer)x_begin.round(System.RoundingMode.CEILING);

		return commonSlice(start, olist.size());
	}

	public List<Object> slice(Decimal x_begin, Decimal x_end){
		Integer start = x_begin == NULL ? 0 : (Integer)x_begin.round(System.RoundingMode.CEILING);
		Integer finish = x_end == NULL ? olist.size() : (Integer)x_end.round(System.RoundingMode.CEILING);

		return commonSlice(start, finish);
	}

	private List<Object> commonSlice(Integer x_begin, Integer x_end){
		List<Object> ret = new List<Object>();
		x_begin = x_begin < 0 ? olist.size() + x_begin : x_begin;
		x_end = x_end < 0 ? olist.size() + x_end : x_end;
		Integer maxIndex = olist.size();

		while (x_begin < maxIndex && x_begin < x_end) {
			ret.add(olist[x_begin]);
			x_begin++;
		}

		return ret;
	}
}