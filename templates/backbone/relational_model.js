var model = Backbone.RelationalModel.extend({

    defaults: {
    },

    relations: [
        {
            type: Backbone.HasOne,
            key: "key",
            relatedModel: Model,
            collectionType: Collection
        }
    ]

});
