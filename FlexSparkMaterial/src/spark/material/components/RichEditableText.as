package spark.material.components
{
    import mx.core.mx_internal;

    use namespace mx_internal;

    import spark.components.RichEditableText;

    public class RichEditableText extends spark.components.RichEditableText
    {
        /*
        long story.. going deep into debug mode, getPreferredBoundsHeight is throwing unwanted values
        because of the private method calculateHeightInLines().
        so.. I overrided to return the real lineHeight instead.
        */
        override public function getPreferredBoundsHeight(postLayoutTransform:Boolean=true):Number
        {
            return textContainerManager.getContentBounds().height;
        }
    }
}
