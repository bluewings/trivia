'use strict'

express = require('express')
slideController = require('./slide.controller')
imageController = require('./slide.image.controller')

router = express.Router()

router.get '/', slideController.index
router.post '/', slideController.create
router.get '/:id', slideController.show
router.put '/:id', slideController.update
router.delete '/:id', slideController.destroy

router.get '/:id/images', imageController.index
router.post '/:id/images', imageController.create
router.delete '/:id/images/:image', imageController.destroy

router.get '/:id/export', slideController.export
router.post '/:id/import', slideController.import

module.exports = router
