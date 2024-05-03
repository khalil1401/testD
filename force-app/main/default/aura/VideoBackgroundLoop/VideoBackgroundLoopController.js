({
	init:function(component,event,helper){
		var bandera = component.get('v.bandera');
		if(bandera === false){
			document.getElementById('video').style.display = 'none';
			document.getElementById('imagen').style.display = 'block';	
		}
		
	},
	canPlay: function(component,event,helper){
		document.getElementById('imagen').style.display = 'none';
		document.getElementById('video').style.display = 'block';
		component.set('v.bandera', true);
	}
})