namespace TemplateReviews;

/// <summary>
/// Provides common arithmetic operations.
/// </summary>
public static class MathHelper
{
    /// <summary>
    /// Returns the sum of two integers.
    /// </summary>
    /// <param name="a">The first operand.</param>
    /// <param name="b">The second operand.</param>
    /// <returns>The sum of <paramref name="a"/> and <paramref name="b"/>.</returns>
    public static int Add(int a, int b) => a + b;

    /// <summary>
    /// Returns the product of two integers.
    /// </summary>
    /// <param name="a">The first operand.</param>
    /// <param name="b">The second operand.</param>
    /// <returns>The product of <paramref name="a"/> and <paramref name="b"/>.</returns>
    public static int Multiply(int a, int b) => a * b;
}
