using Microsoft.VisualStudio.TestTools.UnitTesting;
using TemplateReviews;

namespace TemplateReviews.Tests;

[TestClass]
public class StringHelperTests
{
    [TestMethod]
    public void StringHelper_Reverse_ReturnsReversedString()
    {
        Assert.AreEqual("olleh", StringHelper.Reverse("hello"));
    }

    [TestMethod]
    public void StringHelper_ToUpper_ReturnsUpperCaseString()
    {
        Assert.AreEqual("HELLO", StringHelper.ToUpper("hello"));
    }
}
