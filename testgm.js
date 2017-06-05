var fs = require('fs');
var gm = require('gm');
var tesseract = require('node-tesseract');

//图片分割10份
for(var i=0;i<10; i++ ){
croptosegs('print.jpg',gm,i);
}

//将分割的图片组合
gm('resize0.jpg').append('resize1.jpg','resize2.jpg','resize3.jpg','resize4.jpg','resize5.jpg','resize6.jpg','resize7.jpg','resize8.jpg','resize9.jpg',true)
.write('resize.jpg', function (err) {
  if (!err) {console.log('combination done');}else{console.log('combination error');}
});

//<=========test
//gm('segmentTest.jpg')
//.resize(300, 300)
//.write('Test.jpg', function (err) {
//  if (!err) console.log('Test.done');
//});
//test========>



//参数配置
var options = {
    l: 'num',
    psm: 6, 
	'config': 'digits',
    binary: 'tesseract'
};
// Recognize text of eng in digits
tesseract.process('resize.jpg',options,function(err, text) {
    if(err) {
        console.error(err);
    } else {
        console.log('Recognize results:'+text);
    }
});


//切割函数
function croptosegs (imgPath, obj_gm,i) {
var outname='resize'+i+'.jpg';
obj_gm(imgPath)
.crop(70,75,i*80+4,4)//切割参数
.resize(300, 300)//放大
.write(outname, function (err) {
  if (!err) {console.log('image segmentation done'+i);}else{console.log('image segmentation error'+i);}
});
    
}