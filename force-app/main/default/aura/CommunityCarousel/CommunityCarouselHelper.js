({
	createImageObject: function(component, event, imageName, imagePath, redirectPath){
        let imgName = component.get('v.'.concat(imageName));
        if(!$A.util.isEmpty(imgName)){
            let imgPath = component.get('v.'.concat(imagePath));
            let redirPath = component.get('v.'.concat(redirectPath));
            let imgSrc = $A.get('$Resource.' + imgName) + imgPath;
            let images = component.get('v.images');
            images.push({
                'src' : imgSrc,
                'redirectPath' : redirPath
            });
            component.set('v.images', images);
        }
    }
})