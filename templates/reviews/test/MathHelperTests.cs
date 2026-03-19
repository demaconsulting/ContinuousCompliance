using Microsoft.VisualStudio.TestTools.UnitTesting;
using TemplateReviews;

namespace TemplateReviews.Tests;

[TestClass]
public class MathHelperTests
{
    [TestMethod]
    public void MathHelper_Add_ReturnsSum()
    {
        Assert.AreEqual(5, MathHelper.Add(2, 3));
    }

    [TestMethod]
    public void MathHelper_Multiply_ReturnsProduct()
    {
        Assert.AreEqual(6, MathHelper.Multiply(2, 3));
    }
}
